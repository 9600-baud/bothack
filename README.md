# Bot Hack
This software starts a Mojolicious server on port 3000, listening for any connection on / to the server. It then will use the get arguments to setup the TITLE attribute for vulnerable bots to complete commands. This will only work with bots that directly read HTML TITLEs and do not escape the newline characters.
