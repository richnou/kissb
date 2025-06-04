# Build Signature Verification

The packages we are distributed are provided with a SHA256 Checksum which is signed by our PGP Key:

**Key Email:** signing@kissb.dev<br/>
**Key Fingerprint:** E242 53BA 23A2 452F<br/>
<https://keys.openpgp.org/search?q=signing%40kissb.dev>

To verify a file, first import the key:

    $ gpg --recv-keys 0xE24253BA23A2452F

For a given downloaded file, download the signed checksum, calculate the checksum and verify the signature:

    $ wget {{s3.kissb_dev_250502}}/kissb-250502
    $ wget {{s3.kissb_dev_250502}}/kissb-250502.sha256.asc

Now Calculate the sha256 and save it to a file:

    $ sha256sum -b kissb-250502 > kissb-250502.sha256

Finally, verify the signature using gpg:

    $ gpg --verify  kissb-250502.sha256.asc kissb-250502.sha256
