{ config, pkgs, lib, ... }:
{

  systemd.services.power-profiles-daemon-hooks = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "power-profiles-daemon.service" "handheld-daemon.service" ];
    after = [ "power-profiles-daemon.service" "handheld-daemon.service" "multi-user.target" ];
    path = [ pkgs.power-profiles-daemon pkgs.curl ];
    script = ''
      sleepint=5
      oldstate="none"

      settdp() {
        echo "Setting TDP to $1 W"
        curl -s --out-null -X POST --unix-socket /run/hhd/api --json "{\"tdp\":{\"qam\":{\"tdp\":$1}}}" http://127.0.0.1/api/v1/state
      }
      
      settdpboost() {
        echo "Setting TDP Boost to $1"
        curl -s --out-null -X POST --unix-socket /run/hhd/api --json "{\"tdp\":{\"qam\":{\"boost\":$1}}}" http://127.0.0.1/api/v1/state
      }

      setcpuboost() {
        echo "Setting CPU Boost to $1"
        curl -s --out-null -X POST --unix-socket /run/hhd/api --json "{\"tdp\":{\"amd_energy\":{\"mode\":{\"mode\":\"manual\",\"manual\":{\"cpu_boost\":\"$1\"}}}}}" http://127.0.0.1/api/v1/state
      }

      setcpupref() {
        echo "Setting CPU Pref to $1"
        curl -s --out-null -X POST --unix-socket /run/hhd/api --json "{\"tdp\":{\"amd_energy\":{\"mode\":{\"mode\":\"manual\",\"manual\":{\"cpu_pref\":\"$1\"}}}}}" http://127.0.0.1/api/v1/state
      }

      setgpuupper() {
        echo "Setting max GPU frequency to $1 MHz"
        curl -s --out-null -X POST --unix-socket /run/hhd/api --json "{\"tdp\":{\"amd_energy\":{\"gpu_freq\":{\"mode\":\"upper\",\"upper\":{\"frequency\":$1}}}}}" http://127.0.0.1/api/v1/state
      }

      setsmupolicy() {
        echo "Setting SMU policy to $1"
        curl -s --out-null -X POST --unix-socket /run/hhd/api --json "{\"tdp\":{\"smu\":{\"energy_policy\":\"$1\"}}}" http://127.0.0.1/api/v1/state
      }

      setaspmpolicy() {
        echo "Setting PCIe ASPM policy to $1"
        echo $1 > /sys/module/pcie_aspm/parameters/policy
      }

      while true
      do
        newstate=$(powerprofilesctl get)

        if [ "$oldstate" == "$newstate" ]; then
          sleep $sleepint
          continue
        fi;
        
        echo "Power profile changed from $oldstate to $newstate"

        if [ "$newstate" == "performance" ]; then
          settdp 28
          settdpboost true
          setcpuboost enabled
          setcpupref balance_performance
          setgpuupper 2700
          setsmupolicy performance
          setaspmpolicy performance
        fi;

        if [ "$newstate" == "balanced" ]; then
          settdp 18
          settdpboost false
          setcpuboost disabled
          setcpupref balance_power
          setgpuupper 1700
          setsmupolicy balanced
          setaspmpolicy powersave
        fi;

        if [ "$newstate" == "power-saver" ]; then
          settdp 8
          settdpboost false
          setcpuboost disabled
          setcpupref power
          setgpuupper 800
          setsmupolicy power
          setaspmpolicy powersupersave
        fi;

        oldstate="$newstate"
        sleep $sleepint
      done
    '';
  };

}