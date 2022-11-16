## NUL RDC Development Environment Tools

This suite of tools is designed to make using the NUL RDC Development Environment as easy as possible. It consists of several executable utilities, shell scripts, and helper files.

### Utilities

#### `app-environment`

Write application configuration to an `.envrc` file

Usage:
```
app-environment [app-id]
```

For example, to initialize AVR's environment:

```
$ cd $HOME/environment/avr
$ app-environment avr
```

This will write an `.envrc` file in the AVR working directory that will be loaded every time you `cd` into that directory and unloaded when you `cd` back out.

#### `clean-s3`

Clear all data from an application's S3 buckets.

Usage:
```
clean-s3 [--app APP_ID] [--yes | -y] <dev|test>
```

- `APP_ID` - `avr` or `meadow` (Default: `meadow`)
- If `--yes` or `-y` is not supplied, the script will do a dry run and show what would be deleted

#### `dbconnect`

Attach to the `meadow` dev database in [`psql`](https://www.postgresql.org/docs/12/app-psql.html). Useful for triggering the
Aurora Serverless instance to spin up before attempting other connections.

#### `es-proxy`

Open a proxy to the dev OpenSearch cluster

Usage:
```
es-proxy <start|stop>
```

#### `https-proxy`

Create an HTTPS pass-through proxy to a local HTTP service

Usage:
```
https-proxy <start|stop> HTTPS_PORT [HTTP_PORT]
```

`https://` requests to port `HTTPS_PORT` will be proxied to `http://localhost:HTTP_PORT`

#### `sg`

Manage security group inbound ports

```
Usage:

Open ports/ranges to an address or range:
  sg open <CIDR|all> PORT[-PORT] PORT[-PORT] ...
Close ports/ranges to an address or range:
  sg close <CIDR|all> PORT[-PORT] PORT[-PORT] ...
Close all open ports:
  sg close all
Display all open ports:
  sg show
```

### Login

There are a number of scripts that run on login (every time a shell is opened). These scripts:

- Set up the correct environment for apps and tools to run
- Initialize certain shell hooks like [`asdf`](https://asdf-vm.com/) and [`direnv`](https://direnv.net/)
- Install some shell functions and other helpers

### Updates

The login script runs a `git pull` on the upstream repo on every login, so the tools should be self-updating.
