FROM patrikulus/az-pipelines-agent:windows
#FROM mcr.microsoft.com/windows/servercore

ENV chocolateyUseWindowsCompression=false
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

RUN choco config set cachelocation C:\chococache

RUN choco install \
    git \
    curl \
    visualstudio2019buildtools \
    --package-parameters \ 
    "--add Microsoft.VisualStudio.Workload.VCToolsv \
     --add Microsoft.VisualStudio.Workload.MSBuildTools \
     --includeRecommended --quiet --locale en-US" \
    --confirm

# Separate call, env needs to be refreshed
RUN choco install python3 --confirm && refreshenv
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "$root = ((New-Object System.Net.WebClient).DownloadString('https://bootstrap.pypa.io/get-pip.py')) | python $root"

RUN pip install \
    conan \
    conan_package_tools \
    --upgrade --upgrade-strategy only-if-needed \
    && conan user

COPY ./conan-fallback-settings.yml %USERPROFILE%/.conan/settings.yml

RUN rmdir /S /Q C:\chococache