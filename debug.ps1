https://techcommunity.microsoft.com/t5/containers/removing-the-latest-tag-an-update-on-mcr/ba-p/393045

:1709, :1803, :1809, :ltsc2016 :ltsc2019

docker pull mcr.microsoft.com/windows/servercore:ltsc2019

Get-Content .\tests\Dockerfile | docker build -

$imageId = docker build .\Tests\Docker\dns1 -t dns1 -q # sha256:f6a056ae44ab536242cc2b47d9fa1019874d5e0760806eaa02fc5e014dd962f4

# docker build .\Tests\Docker\dns1 -t dns1

# This is used to allow COPY to get to file outside of build context.
cd c:\source\xDsnServer # root of repo
docker build -f .\Tests\Docker\dns1\Dockerfile -t dns1 .
$imageId = docker inspect --format "{{.ID}}" dns1:latest
$containerId = docker run --detach --name dns1 $imageId
docker ps
# Must run as local admin, otherwise throws ".. does not exist, or the corresponding container is not running."
Enter-PSSession -ContainerId $containerId -RunAsAdministrator

docker stop $containerId
docker rm $containerId

docker rmi $imageId
C:\source\xDnsServer [f/container-integ-test +1 ~0 -0 !]> docker run --detach 929ecb1df3f0
6da7d1321b38172b34a37d071b28cdb1e9399176e8fe6c31b593ec778e3ee250

docker run -d -p 8080:8080 --name websitecontainer myiis
