# TY33A WiFi Weak Signal Issue - Analysis & Fixes

## Problem Summary

TY33A boards with RTL8723CS WiFi chipset fail to connect or lose connection when WiFi signal is medium/weak (e.g., signal strength ~54%).

## Root Causes Identified

### 1. **Conflicting Power Management Patches**

The kernel configuration applied conflicting patches:

- `8723cs-Disable-power-saving.patch` - Disables power saving
- `8723cs-Enable-wifi-power-saving-mode.patch` - Enables aggressive power saving

The latter patch **overrides** the former, enabling power saving modes that prioritize battery life over connectivity stability:

- `CONFIG_POWER_SAVING = y`
- `CONFIG_IPS_MODE = 0` (Inactive Power Save)
- `CONFIG_LPS_MODE = 1` (Legacy Power Save)

**Impact**: The driver aggressively reduces power on weak signals, causing disconnections.

### 2. **Missing Runtime Configuration**

The `8723cs.conf` modprobe configuration file exists with optimal settings but was never installed:

```
options 8723cs rtw_power_mgnt=0 rtw_ips_mode=0 rtw_btcoex_enable=0
```

**Impact**: Even if kernel config is correct, runtime power management wasn't disabled.

### 3. **Insufficient NetworkManager Tuning**

NetworkManager lacked WiFi-specific optimizations for weak signal scenarios:

- No DHCP timeout adjustments
- Default power save settings
- No explicit weak signal handling

## Debugging Guide

### On-Device Diagnostics

#### 1. Check Driver Status

```bash
# Verify driver is loaded
lsmod | grep 8723cs

# Check current power management parameters
cat /sys/module/8723cs/parameters/rtw_power_mgnt  # Should be 0
cat /sys/module/8723cs/parameters/rtw_ips_mode    # Should be 0
cat /sys/module/8723cs/parameters/rtw_btcoex_enable

# Check interface power save status
iwconfig wlan0  # Power Management should be "off"
```

#### 2. Monitor Signal and Connection Quality

```bash
# Real-time signal monitoring
watch -n1 'iw dev wlan0 link; iwconfig wlan0'

# Detailed WiFi status
nmcli -f all device show wlan0
nmcli device wifi list

# Check for errors/drops
ip -s link show wlan0
ethtool -S wlan0 | grep -iE 'error|drop|retry|fail'
```

#### 3. Analyze Logs

```bash
# Driver messages
dmesg | grep -iE '8723|rtl|wifi|wlan' | tail -50

# NetworkManager logs
journalctl -u NetworkManager -f

# Check for disconnection events
journalctl -u NetworkManager --since "10 minutes ago" | grep -iE 'disconnect|deauth|signal'
```

#### 4. Test Power Save Modes

```bash
# Temporarily disable power save
iw dev wlan0 set power_save off

# Verify it's disabled
iwconfig wlan0

# If this improves connectivity, power save is the issue
# Monitor connection stability for 5-10 minutes
```

#### 5. Check Module Load Parameters

```bash
# Verify modprobe configuration is loaded
modprobe -c | grep 8723cs

# Should show:
# options 8723cs rtw_power_mgnt=0 rtw_ips_mode=0 rtw_btcoex_enable=0
```

#### 6. Network Performance Testing

```bash
# Test with different signal levels
ping -c 100 -i 0.2 <router-ip>

# Monitor packet loss
mtr -c 100 <router-ip>

# Speed test with weak signal
iperf3 -c <server-ip> -t 30
```

### Advanced Debugging

#### Enable Driver Debug Logs

```bash
# Increase kernel log level
echo 7 > /proc/sys/kernel/printk

# Enable RTL8723CS debug (if supported)
echo 1 > /sys/module/8723cs/parameters/debug
```

#### Capture Traffic

```bash
# Install tcpdump if available
tcpdump -i wlan0 -w /tmp/wifi_capture.pcap

# Analyze for deauth/disassoc packets
tcpdump -r /tmp/wifi_capture.pcap -n 'type mgt subtype deauth or type mgt subtype disassoc'
```

## Applied Fixes

### 1. Removed Conflicting Power Save Patch

**File**: `layers/meta-balena-allwinner/recipes-kernel/linux/linux-mainline_%.bbappend`

**Change**: Removed `8723cs-Enable-wifi-power-saving-mode.patch` from patch series

**Effect**: Driver now builds with power saving **disabled** at compile time

### 2. Installed Runtime Power Management Configuration

**File**: `layers/meta-balena-allwinner/recipes-kernel/linux/linux-mainline_%.bbappend`

**Added**:

```bitbake
do_install:append:ty33a-8g1g() {
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${WORKDIR}/wireless-rtl8723cs/8723cs.conf ${D}${sysconfdir}/modprobe.d/
}
```

**Effect**: Modprobe configuration is now installed to `/etc/modprobe.d/8723cs.conf`, ensuring power management is disabled even if driver defaults change.

### 3. Enhanced NetworkManager Configuration

**File**: `layers/meta-balena-allwinner/recipes-connectivity/networkanager/networkmanager_%.bbappend`

**Added**:

```ini
[connection]
ipv4.dhcp-timeout=90
ipv6.dhcp-timeout=90

[wifi]
powersave=2  # 0=default, 1=ignore, 2=disable, 3=enable
scan-rand-mac-address=no
backend=wpa_supplicant
```

**Effect**:

- Increased DHCP timeouts for slow weak-signal connections
- Explicitly disabled WiFi power save in NetworkManager
- Disabled MAC randomization (already configured, now in wifi section)

### 4. Created WiFi Tuning Service

**New Package**: `rtl8723cs-wifi-tune`

**Purpose**: Runtime optimization applied at boot and when WiFi interface becomes available

**Components**:

- `rtl8723cs-wifi-tune.bb` - Recipe definition
- `rtl8723cs-wifi-tune.service` - Systemd service
- `rtl8723cs-wifi-tune.sh` - Tuning script

**Actions Performed**:

```bash
# Disable interface power save
iw dev wlan0 set power_save off

# Maximize TX power
iwconfig wlan0 txpower auto

# Ensure driver power management is disabled
echo 0 > /sys/module/8723cs/parameters/rtw_power_mgnt
echo 0 > /sys/module/8723cs/parameters/rtw_ips_mode

# Optimize kernel network stack
sysctl -w net.ipv4.tcp_congestion_control=bbr
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
```

### 5. Integrated Tuning Package

**File**: `layers/meta-balena-allwinner/recipes-core/packagegroups/packagegroup-balena-connectivity.bbappend`

**Added**: `RDEPENDS:${PN}:append:ty33a-8g1g = " rtl8723cs-wifi-tune"`

**Effect**: The tuning service is automatically included in TY33A builds.

## Testing Plan

### 1. Build Verification

```bash
cd /Users/noahdressler/BitBucket/balena-allwinner
./balena-yocto-scripts/build/balena-build.sh -m ty33a-8g1g -a armv7hf
```

### 2. Runtime Verification (on device)

```bash
# 1. Check modprobe config is installed
cat /etc/modprobe.d/8723cs.conf

# 2. Verify driver parameters
cat /sys/module/8723cs/parameters/rtw_power_mgnt  # Should be 0
cat /sys/module/8723cs/parameters/rtw_ips_mode    # Should be 0

# 3. Check NetworkManager config
grep -A5 '^\[wifi\]' /etc/NetworkManager/NetworkManager.conf

# 4. Verify tuning service is running
systemctl status rtl8723cs-wifi-tune.service

# 5. Check interface power save is off
iwconfig wlan0 | grep "Power Management"
```

### 3. Connectivity Testing

```bash
# Test at various signal levels (move device or adjust AP power)
# Signal range: 30-60% (weak to medium)

# 1. Initial connection test
nmcli device wifi connect "SSID" password "PASSWORD"

# 2. Monitor for 30+ minutes
watch -n10 'date; iw dev wlan0 link | grep signal; nmcli -f GENERAL device show wlan0 | grep STATE'

# 3. Ping test
ping -c 1000 -i 1 <gateway> | tee /tmp/ping_results.txt

# 4. Analyze packet loss
grep 'packet loss' /tmp/ping_results.txt
```

## Expected Improvements

1. **Connection Stability**: Devices should maintain connections at signal levels as low as 40-50%
2. **Reconnection Speed**: Faster reconnection after temporary signal loss
3. **DHCP Success**: Improved DHCP acquisition on weak signals (90s timeout)
4. **No Power Save Interference**: Consistent TX power regardless of signal strength

## Fallback Options (if issues persist)

### Option 1: Adjust TX Power

```bash
# On device, test with increased TX power
iwconfig wlan0 txpower 20dBm  # or specific value
```

### Option 2: Disable BT Coexistence (if using Bluetooth)

Already configured in `8723cs.conf`:

```
rtw_btcoex_enable=0
```

### Option 3: Channel Optimization

```bash
# Force specific channel on AP (2.4GHz: 1, 6, 11 are best)
# Avoid channels 12-14 if driver has regulatory issues
```

### Option 4: Antenna Check

- Verify antenna connections (hardware)
- Check for RF shielding issues in enclosure

### Option 5: Driver Alternative

Consider upgrading to newer RTL8723CS driver from:

- https://github.com/jwrdegoede/rtl8189ES_linux (current)
- https://github.com/hadess/rtl8723cs (alternative fork)

## Additional Configuration Options

### If Issues Persist - Add to kernel defconfig:

```
CONFIG_CFG80211_CERTIFICATION_ONUS=y
# Allows regulatory domain changes
```

### NetworkManager Additional Tweaks:

```ini
[connection]
connection.auth-retries=5
ipv4.may-fail=no

[device-ty33a-wifi]
match-device=driver:8723cs
wifi.scan-rand-mac-address=no
wifi.powersave=2
```

## Monitoring & Metrics

### Key Metrics to Track

1. **Signal Strength**: RSSI in dBm (aim for > -75 dBm)
2. **Signal Quality**: Link quality % (aim for > 40%)
3. **TX Bitrate**: Should adapt but not drop to minimum
4. **Packet Loss**: Should be < 1% on good AP
5. **Reconnection Time**: After signal loss (aim for < 10s)

### Log Locations

- Driver: `dmesg` or `journalctl -k`
- NetworkManager: `journalctl -u NetworkManager`
- WiFi events: `/var/log/syslog` or `journalctl -f`

## References

- RTL8723CS Driver: https://github.com/jwrdegoede/rtl8189ES_linux
- BalenaOS Networking: https://www.balena.io/docs/reference/OS/network/
- Linux WiFi: https://wireless.wiki.kernel.org/
- iw documentation: https://wireless.wiki.kernel.org/en/users/documentation/iw

## Files Changed Summary

1. `layers/meta-balena-allwinner/recipes-kernel/linux/linux-mainline_%.bbappend`

   - Removed conflicting power save patch
   - Added modprobe config installation
   - Added 8723cs.conf to SRC_URI

2. `layers/meta-balena-allwinner/recipes-connectivity/networkanager/networkmanager_%.bbappend`

   - Enhanced WiFi configuration
   - Added DHCP timeouts
   - Disabled power save explicitly

3. `layers/meta-balena-allwinner/recipes-connectivity/rtl8723cs-wifi-tune/` (NEW)

   - Created complete tuning package
   - Systemd service for runtime optimization
   - Comprehensive tuning script

4. `layers/meta-balena-allwinner/recipes-core/packagegroups/packagegroup-balena-connectivity.bbappend`
   - Added rtl8723cs-wifi-tune dependency for TY33A

## Next Steps

1. **Build** the updated OS image
2. **Flash** to TY33A device
3. **Test** in weak signal conditions (signal ~40-60%)
4. **Monitor** logs and metrics for 24+ hours
5. **Report** findings and adjust if needed

## Support

If issues persist after these changes:

1. Capture full logs: `journalctl -b > /tmp/full_boot_log.txt`
2. WiFi scan results: `iw dev wlan0 scan > /tmp/wifi_scan.txt`
3. Module info: `modinfo 8723cs > /tmp/module_info.txt`
4. System info: `uname -a; cat /proc/cpuinfo; cat /etc/os-release`
