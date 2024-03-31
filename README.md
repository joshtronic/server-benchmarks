# Server Benchmarks

Server benchmarking script for the [VPS Showdown][vps] posts on my blog,
[joshtronic.com][blog].

I hope that by liberating them, we can make them better, together.

## Requirements

This script is designed to be run on Ubuntu 22.04 LTS. It is likely to work on
other versions of Ubuntu and Debian, but is only maintained for the latest LTS.

## Usage

To run these benchmarks, simply execute the `run.sh` script, passing in the name
of the hosting provider (any string really) as the first argument:

```shell
./run.sh hosting-provider
```

The provider name is used when creating the compressed archive of the results.

## License

Licensed under the GNU General Public License v3.

## Support

If you found my [VPS Showdown][vps] posts or this script helpful in picking a
new hosting provider, please considering using one of my referral links for
[DigitalOcean][do], [Linode][linode], [UpCloud][uc] or [Vultr][vultr] when
signing up.

If you would prefer to support me directly, you can [buy me a coffee][coffee].

[blog]: https://joshtronic.com
[vps]: https://joshtronic.com/category/vps-showdown/
[do]: https://m.do.co/c/c35d26de972b
[linode]: https://www.linode.com/lp/refer/?r=5f682793582e82ce686747c851b998dc1f86a55b
[uc]: https://upcloud.com/signup/?promo=XZN2AZ
[vultr]: https://www.vultr.com/?ref=8946490-8H
[coffee]: https://ko-fi.com/joshtronic
