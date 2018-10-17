
WebSupport DNS is a DDNS tool for websupport.sk users using CNAME records. Project is written in Swift 4.2 and uses Alamofire and ObjectMapper as only dependencies. Remote IP address is obtained from https://ipify.org


This project uses Cocoapods. Run following command to install all dependencies:

    $ pod install

Then open .xcworkspace project file in Xcode to build the project.

You will need to add configuration file at ~/.websupport.plist and add entries as depicted below. This will also require to add CNAME entries at https://admin.websupport.sk for your domain.

Let's say you have following domain:

    www.somedomain.com

And you would like this app to update CNAME records for following subdomains with your current IP address (checks are done every 5 minutes):

    api.somedomain.com
    dev.somedomain.com

Configuration file will look like this:

    {
        Login = "admin";
        Password = "l33th4xx0r";
        UpdateInterval = 5;
        Zone = "somedomain.com";
        Records = (
                dev,
                api,
        );
    }
