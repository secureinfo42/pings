# pings

A "Solaris-like" ping

# Synopsis

```
Usage: pings <host>

Send one ICMP request to know if host is dead or alive. Timeout is 3s.
```

# Output

```
$ pings 185.15.58.99
185.15.58.99 seems dead.

$ pings 185.15.58.224
185.15.58.224 is alive, ttl:49

$ pings wikipedia.org
wikipedia.org (185.15.58.224) is alive, ttl:49
```
