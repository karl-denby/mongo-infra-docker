**Queryable:**
- On M1/ARM 6.0.15 has been downloaded and renamed as if it was an x86_64 binary
- Ops Manager always assumes it runs on x86 so when a queryable restore for version 6.0.0 through 6.0.14 is this will be used
- If you decided to use version 6.0.15 for something else it may get overwriten so avoid that
- If you want to do queryable on another version, download the equivalent aarch64/rhel8 binary and rename it as x86_64
- You also need to ensure its owner:group is set to mongodb-mms:mongodb-mms
- On x86_64 everything should just work as OM can just download what it needs