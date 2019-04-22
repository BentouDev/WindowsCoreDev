FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV chocolateyUseWindowsCompression=false
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

RUN choco config set cachelocation C:\chococache

RUN choco install \
    git \
    curl \
    visualstudio2019buildtools \
    --package-parameters \ 
    "--add Microsoft.VisualStudio.Workload.NativeGame \
     --add Microsoft.VisualStudio.Workload.NativeDesktop \
     --includeRecommended --quiet --locale en-US" \
    --confirm \
	&& rmdir /S /Q C:\chococache

# Separate call, env needs to be refreshed
RUN choco install python3 --confirm \
	&& refreshenv \
	&& rmdir /S /Q C:\chococache
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "$root = ((New-Object System.Net.WebClient).DownloadString('https://bootstrap.pypa.io/get-pip.py')) | python $root"

RUN pip install \
    conan \
    conan_package_tools \
    --upgrade --upgrade-strategy only-if-needed \
    && conan user

COPY ./conan-fallback-settings.yml %USERPROFILE%/.conan/settings.yml

# Attempt to install Qt 5.12.1
RUN git clone https://github.com/benlau/qtci.git \
    && @powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://download.qt.io/archive/qt/5.12/5.12.1/qt-opensource-windows-x86-5.12.1.exe -OutFile ./qt-installer.exe" \
    && "C:\Program Files\Git\bin\bash.exe" --noprofile --norc -c "source qtci/path.env && extract-qt-installer qt-installer.exe ~/Qt && ls -al ~/Qt" \
    && rm qt-installer.exe

ENV QTDIR=%USERPROFILE%/Qt/5.12.1/msvc2017_64/