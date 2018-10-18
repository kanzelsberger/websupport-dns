
WebSupport DNS is a DDNS tool for websupport.sk users using A or CNAME records. Project is written in Swift 4.2 and uses Alamofire and ObjectMapper as only dependencies. Remote IP address is obtained from https://ipify.org


This project uses Cocoapods. Run following command to install all dependencies:

    $ pod install

Then open .xcworkspace project file in Xcode to build the project.

You will need to add configuration file at ~/.websupport.plist and add entries as depicted below. This will also require to add A and/or CNAME entries at https://admin.websupport.sk for your domain. This tool updates your selected A records with your current IP address. You can then setup multiple CNAME records that point to your A record.

Let's say you have following domain:

    www.somedomain.com

And you would like this app to update A records for following subdomains with your current IP address (checks are done every 5 minutes). CNAME entries should point to one of these A records.

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
