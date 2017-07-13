function Get-LocalEncryptionCertificateThumbprint {
    (dir Cert:\LocalMachine\My) | %{
        if ($_.PrivateKey.KeyExchangeAlgorithm -and $_.Verify())
        {
            return $_.Thumbprint
        }
    }
}