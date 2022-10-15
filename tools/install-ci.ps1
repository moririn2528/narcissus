#install golang ci
# binary will be $(go env GOPATH)/bin/golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.49.0
golangci-lint --version
$code=$?
if(!$code){
    Write-Host "golangci-lint install failed"
    exit
}

# install git secret
git clone https://github.com/awslabs/git-secrets.git
Set-Location git-secrets
./install.ps1
Set-Location ../
Remove-Item -Recurse -Force git-secrets

# change git hook folder
git config --local core.hooksPath .githooks
