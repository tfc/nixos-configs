{ ... }:

let
  # Legal setting, tied to location. Override when travelling: sudo iw reg set DE
  regulatoryDomain = "PL";
in
{
  networking.networkmanager.enable = true;

  # Without this, setting a country silently does nothing.
  hardware.wirelessRegulatoryDatabase = true;

  # MediaTek MT7925 (RZ717) on mt7925e.
  boot.extraModprobeConfig = ''
    # Domain "00" marks the 5 GHz DFS channels no-transmit, so APs on them
    # time out during auth: visible in scans, impossible to associate with.
    options cfg80211 ieee80211_regdom=${regulatoryDomain}

    # MediaTek's own regulatory layer, which can undo the setting above.
    options mt7925_common disable_clc=1

    # Enable if dmesg shows mt7925 resets or MCU timeouts. Costs idle battery.
    # options mt7925e disable_aspm=1
  '';

  # Latency spikes and deauth cycles on mt76 outweigh the power saved.
  # Authoritative reading: iw dev wlp192s0 get power_save
  networking.networkmanager.wifi.powersave = false;

  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp192s0";
}
