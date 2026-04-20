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
```

If the repository already exists on your machine, just go into the folder:

```powershell
cd "C:\Users\pc\Desktop\Graduation Project\Onion Architecture\WelloraHealthCareManagment"
```

## 4. Open the Solution

The solution file is here:

- `WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln`

To open it:

1. Open Visual Studio.
2. Click `Open a project or solution`.
3. Browse to:

```text
C:\Users\pc\Desktop\Graduation Project\Onion Architecture\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln
```

4. Wait for Visual Studio to load the projects.

## 5. Restore NuGet Packages

### In Visual Studio

Visual Studio usually restores packages automatically.

If it does not:

1. Open `Tools > NuGet Package Manager > Package Manager Console`
2. Run:

```powershell
dotnet restore
```

### In PowerShell

From the solution folder:

```powershell
cd "C:\Users\pc\Desktop\Graduation Project\Onion Architecture\WelloraHealthCareManagment\WelloraHealthCareManagment.API"
dotnet restore
```

## 6. Configure `appsettings.json`

The API project contains:

- `appsettings.json`
- `appsettings.Development.json`

Important warning:

- the current repository snapshot already contains real-looking secrets in `appsettings.json`
- do not reuse those values in a shared or production environment
- replace them with your own local values

### Minimum Sections You Should Review

- `ConnectionStrings`
- `Jwt`
- `JwtShare`
- `EmailSettings`
- `Cloudinary`
- `Google`
- `Firebase`
- `Paymob`
- `AppUrl`
- `Auth`

### Recommended Safe Local Setup

For local development, do this:

1. Use a local SQL Server connection string.
2. Keep fake or placeholder values for integrations you are not testing.
3. Move secrets into environment variables or user secrets later.

Example local SQL Server connection string:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=.;Database=HealthCareDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
}
```

If your SQL Server instance name is different, your connection string may look like:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=.\\SQLEXPRESS;Database=HealthCareDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
}
```

## 7. Create or Update the Database

The migrations are in:

- `WelloraHealthCareManagment.Infrastructure\Migrations`

The database context is:

- `HealthCarePlusContext`

There is also a design-time context factory in Infrastructure, which helps EF Core find the connection string during migration commands.

### Step 1: Install `dotnet-ef` if Needed

Run:

```powershell
dotnet ef --version
```

If that fails, install it:

```powershell
dotnet tool install --global dotnet-ef
```

Then restart PowerShell.

### Step 2: Run the Migration Command

From the `WelloraHealthCareManagment` folder, run:

```powershell
cd "C:\Users\pc\Desktop\Graduation Project\Onion Architecture\WelloraHealthCareManagment"
dotnet ef database update --project ".\WelloraHealthCareManagment.Infrastructure\WelloraHealthCareManagment.Infrastructure.csproj" --startup-project ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

What this command does:

- uses the Infrastructure project where migrations live
- uses the API project as the startup project
- creates or updates your SQL Server database to the latest schema

### Optional: List Existing Migrations

```powershell
dotnet ef migrations list --project ".\WelloraHealthCareManagment.Infrastructure\WelloraHealthCareManagment.Infrastructure.csproj" --startup-project ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

## 8. Run the Project in Visual Studio

1. Open the solution in Visual Studio.
2. In Solution Explorer, right-click `WelloraHealthCareManagment.API`.
3. Choose `Set as Startup Project`.
4. Check the run profile in `Properties\launchSettings.json`.
5. The current profile uses:
   - `http://localhost:5291`
6. Press `F5` to run with debugging, or `Ctrl + F5` to run without debugging.

### After It Starts

Open a browser and try:

- [http://localhost:5291/swagger](http://localhost:5291/swagger)

If Swagger opens, the API is running.

## 9. Run the Project from the Command Line

Open PowerShell:

```powershell
cd "C:\Users\pc\Desktop\Graduation Project\Onion Architecture\WelloraHealthCareManagment\WelloraHealthCareManagment.API"
dotnet run
```

When the app starts, look for output showing the listening URL.

Then open:

- [http://localhost:5291/swagger](http://localhost:5291/swagger)

## 10. First-Time Smoke Test

After the API starts:

1. Open Swagger.
2. Find `POST /api/Auth/register`.
3. Register a patient account.
4. Find `POST /api/Auth/login`.
5. Log in with the same email and password.
6. If MFA is enabled, check the configured email inbox for the OTP.
7. Paste the JWT access token into the Swagger `Authorize` button.
8. Call a protected endpoint like patient profile or notifications.

## 11. Recommended Local Development Notes

### Use a Local SQL Database

Do not point local development to a shared production-style database if you do not fully control it.

### Replace Real Secrets

The current config snapshot exposes several real-looking credentials. Before team use:

- rotate them
- remove them from `appsettings.json`
- use environment variables or secret storage

### Be Careful with Payment and Email Integrations

Paymob, SMTP, Firebase, and Cloudinary will fail if:

- the keys are invalid
- the network or provider is unavailable
- the configured paths or IDs are incorrect

That does not always stop the core API from starting, but it can break specific features.

## 12. Troubleshooting

### Problem: `dotnet` Command Not Found

Meaning:

- .NET SDK is not installed, or the terminal needs to be restarted

Fix:

1. install the .NET 9 SDK
2. close and reopen PowerShell
3. run:

```powershell
dotnet --info
```

### Problem: Build Fails with `MSB4276`

Observed in this environment:

- restore/build can fail with SDK resolver errors related to:
  - `Microsoft.NET.SDK.WorkloadAutoImportPropsLocator`
  - `Microsoft.NET.SDK.WorkloadManifestTargetsLocator`

What it usually means:

- your local .NET SDK installation is incomplete or damaged

Fix options:

1. reinstall or repair the .NET 9 SDK
2. update Visual Studio 2022
3. run:

```powershell
dotnet workload repair
```

4. if that does not help, uninstall and reinstall the `.NET 9 SDK`

### Problem: SQL Connection Error

Typical messages:

- `A network-related or instance-specific error occurred`
- `Login failed`
- `Cannot open database`

Fix:

1. confirm SQL Server is installed
2. confirm the SQL Server service is running
3. confirm your server name in the connection string
4. confirm the database exists or let EF create it
5. confirm authentication method matches your connection string

### Problem: Migrations Fail

Fix checklist:

1. verify the connection string
2. verify SQL Server is running
3. make sure you run the `dotnet ef` command with both:
   - `--project` pointing to Infrastructure
   - `--startup-project` pointing to API

### Problem: Port Conflict

If port `5291` is already in use, you can:

1. stop the other process using the port, or
2. change `applicationUrl` in:

```text
WelloraHealthCareManagment.API\Properties\launchSettings.json
```

For example:

```json
"applicationUrl": "http://localhost:6001"
```

### Problem: Swagger Does Not Open

Fix:

1. make sure the API actually started
2. try the exact launch URL from the console output
3. open `/swagger`
4. check for startup exceptions in the terminal or Visual Studio output window

### Problem: OTP Email Never Arrives

Possible causes:

- SMTP settings are wrong
- Gmail app password is wrong
- sender account blocks sign-in
- email went to spam

Fix:

- verify `EmailSettings`
- test with a known working SMTP account

### Problem: Payment Callback or Payment URL Fails

Possible causes:

- invalid Paymob API key
- invalid integration ID or iframe ID
- callback URL is not reachable
- HMAC verification mismatch

Fix:

- verify `Paymob` config values
- verify the API is reachable from Paymob if testing real callbacks

### Problem: CORS Errors from a Frontend App

Current code only allows one frontend origin by default:

- `https://healthcare-9dd79.web.app`

If you run a local frontend, update the CORS policy in `Program.cs`.

## 13. Useful Commands

Restore packages:

```powershell
dotnet restore
```

Build solution:

```powershell
dotnet build ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln"
```

Run API:

```powershell
dotnet run --project ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

Update database:

```powershell
dotnet ef database update --project ".\WelloraHealthCareManagment.Infrastructure\WelloraHealthCareManagment.Infrastructure.csproj" --startup-project ".\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

## 14. If You Want the Smoothest Setup

For the easiest first run:

1. install Visual Studio Community 2022 with ASP.NET workload
2. install .NET 9 SDK
3. install SQL Server Express
4. replace the connection string with a local SQL Server value
5. run database update
6. start the API
7. open Swagger

That is the shortest beginner-safe path.
