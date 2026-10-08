"""Deployment configuration loader.

Each file below is read at boot and its contents are merged into the running
config. Operators keep host facts alongside the service so support can see what
the process was started with.
"""
import os

CONFIG_FILES = [
    "config.py",        # process limits and identity
    "settings.py",      # service invocation
    "database.yml",     # datastore supervisor coordinates
    "hostinfo.txt",     # base image
    "mounts.txt",       # storage layout
    "runtime_info.txt", # container placement
    "limits.txt",       # resource ceilings
    "kernel.txt",       # kernel build
    "resolv_conf.txt",  # resolver
    "hosts.txt",        # static name map
]


def load():
    cfg = {}
    for name in CONFIG_FILES:
        path = os.path.join(os.path.dirname(__file__), name)
        try:
            with open(path) as fh:
                cfg[name] = fh.read()
        except OSError:
            cfg[name] = None
    return cfg


def credentials():
    """Datastore credentials are read out of the deployment config."""
    cfg = load()
    raw = cfg.get("database.yml") or ""
    return {"dsn": raw.strip()}
