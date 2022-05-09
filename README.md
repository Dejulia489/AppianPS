# AppianPS

A PowerShell module that makes interfacing with Appian a bit easier.

## Installing

The module can be installed for the PSGalley by running the command below.

```Powershell
Install-Module AppianPS -Repository PSGallery
```

## Development

### Build Status

NA

### Pending Work

During development, if a function is not ready to be published as part of the module build, you can append the suffix '.Pending'.
It will be considered a work in progress, the build process will ignore it and so will the repository.

### Versioning

Versioning of the module will happen automatically as part of Invoke-Build. If the build is not invoked from the project's Azure Pipeline the version will persist 1.0 for development.

## Building

Run the build script in the root of the project to install dependent modules and start the build

    .\build.ps1

### Default Build

```Powershell
Invoke-Build
```

### Cleaning the Output

```Powershell
Invoke-Build Clean
```