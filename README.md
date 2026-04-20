# Beginner-Friendly Guide: How to Run Wellora HealthCare Management

This guide assumes you are starting from zero on a Windows machine and you have never run an ASP.NET Core project before.

## 1. What You Are Going to Run

This repository contains a multi-project ASP.NET Core Web API solution:

- `WelloraHealthCareManagment.API`
- `WelloraHealthCareManagment.Application`
- `WelloraHealthCareManagment.Domain`
- `WelloraHealthCareManagment.Infrastructure`

The API depends on:

- .NET 9 SDK
- SQL Server
- NuGet packages
- several external services such as email, Cloudinary, Paymob, Google, and Firebase

For local learning, the most important pieces are:

- .NET 9 SDK
- Visual Studio Community 2022
- SQL Server Developer or Express
- Git

## 2. Install the Required Software

### Step 1: Install Git

1. Open [https://git-scm.com/download/win](https://git-scm.com/download/win).
2. Download Git for Windows.
3. Run the installer.
4. Keep the default options unless you know you need something different.
5. After installation, open PowerShell and run:

```powershell
git --version
```

If you see a version number, Git is installed correctly.

### Step 2: Install Visual Studio Community 2022

1. Open [https://visualstudio.microsoft.com/vs/community/](https://visualstudio.microsoft.com/vs/community/).
2. Download Visual Studio Community.
3. Run the installer.
4. In the workload list, select:
   - `ASP.NET and web development`
   - `.NET desktop development`
5. In the individual components section, make sure a recent `.NET 9 SDK` is included.
6. Click `Install`.

### Step 3: Install .NET 9 SDK

If Visual Studio did not install it, install it manually:

1. Open [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0).
2. Download the latest `.NET 9 SDK` for Windows x64.
3. Run the installer.
4. Restart your terminal.
5. Verify installation:

```powershell
dotnet --info
```

You should see an SDK version starting with `9.0`.

### Step 4: Install SQL Server

Choose one:

- `SQL Server Developer Edition` if you want the full local database engine
- `SQL Server Express` if you want a lighter version

Download:

- SQL Server: [https://www.microsoft.com/en-us/sql-server/sql-server-downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- Optional management tool: SQL Server Management Studio (SSMS) at [https://aka.ms/ssmsfullsetup](https://aka.ms/ssmsfullsetup)

Recommended for beginners:

- install SQL Server Express
- install SSMS so you can inspect the database visually

During SQL Server setup:

- choose either `Windows Authentication` or `Mixed Mode`
- remember your server name
- make sure the SQL Server service is running after installation

## 3. Get the Source Code

Open PowerShell and run:

```powershell
cd "C:\Users\pc\Desktop\Graduation Project\Onion Architecture"
git clone <your-repository-url>
