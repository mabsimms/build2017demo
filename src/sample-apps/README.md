# The raffle sample application

To create some representative data for the demo, I put together a highly contrived
sample application using ASP.NET Core, intended to be deployed as part of a 
set of Docker containers.

The application is an utterly trivial "raffle" application (that I haven't added
any sample data to yet :) with two controllers exposed (ping - get server time, and
raffle, get list of raffles from database or redis).

As part of the overall demo flow, there are three incarnations of the app:

- [Baseline](./0.baseline/).  The starting point for the application, with a three-container deployment of ASP.NET Core, redis and SQL Server.

- [Lights On](./1.lightson/).  An updated deployment, with an instrumented haproxy fronting the ASP.NET application (no code changes to the ASP.NET application).

- [Bugfix](./2.bugfix/).  A further update that resolves the utterly contrived bug in the original application.

