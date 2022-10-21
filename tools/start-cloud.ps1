Param($cloud)
if($cloud -eq "") {
    $cloud="nar"
}
Write-Host $cloud
$git_directory=$(git rev-parse --show-toplevel)
Set-Location $git_directory
ssh $cloud "sudo apt install -y git && git clone git@github.com:jphacks/D_2202.git narcissus"

scp "./docker/cloud/startup.sh" "${cloud}:startup.sh"

ssh $cloud "sudo chmod 755 startup.sh && ./startup.sh"
scp "./docker/local/.env" "${cloud}:narcissus/docker/local/.env"
ssh $cloud "cd narcissus/docker/local && docker compose build && docker compose up -d"

Write-Host finished