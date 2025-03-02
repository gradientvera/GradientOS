/*
  I guess I do hosting for other people now?
 */
{ self, ... }:
{

    services.nginx.virtualHosts = {
      "crp3092.com" = {
        root = self.inputs.crp3092;
        enableACME = true;
        addSSL = true;
        serverAliases = [
          "www.crp3092.com"
        ];
      };
    };

}