
For a correct first-time setup, these roles must exist in the database. If they are not created automatically by your local workflow, they must be inserted or seeded before full role-based testing can be completed.

## Compilation Steps

### Build the Entire Solution

```powershell
dotnet build ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.sln" -c Debug
```

### Build the API Project Directly

```powershell
dotnet build ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj" -c Debug
```

## Run Instructions

### Option 1: Run from Visual Studio

1. Open the solution.
2. Set `WelloraHealthCareManagment.API` as the startup project.
3. Run the project using `F5` or `Ctrl + F5`.

### Option 2: Run from PowerShell

```powershell
dotnet run --project ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj"
```

### Local Development URL

Based on the current launch settings, the API runs locally on:

- `http://localhost:5291`

Swagger should be available at:

- `http://localhost:5291/swagger`

### Hosted Swagger Endpoint

The deployed Swagger endpoint currently referenced by the team is:

- [Wellora Swagger](https://wellora-healthcaremanagment.runasp.net/swagger/index.html)

## Pre-built Executable Setup

This repository includes the required `/exe` directory for publish output.

### How to Generate the Executable / Published Backend

From the repository root:

```powershell
dotnet publish ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj" -c Release -o ".\exe\backend"
```

This command generates a publish-ready backend build inside:

```text
exe\backend
```

### Download and Installation Instructions

If the `exe\backend` folder is published and committed by the team, another user can:

1. Download or clone the repository
2. Open the `exe\backend` folder
3. Ensure the required configuration files and secrets are available
4. Run the published application

### Run the Published Application

If the publish output contains the framework-dependent DLL build, use:

```powershell
dotnet .\exe\backend\WelloraHealthCareManagment.API.dll
```

If a self-contained executable is produced in future publishing steps, it can be launched directly from the `exe\backend` folder.

### Required Prerequisites for Published Output

Depending on publish mode, the user may still need:

- .NET 9 runtime
- SQL Server access
- valid configuration files
- external service credentials

## Flutter Application Note

The backend is clearly prepared to work with a Flutter mobile client, and the repository includes Flutter integration guides inside:

```text
src\WelloraHealthCareManagment\docs
```

However:

- no standalone Flutter source project was found in this repository snapshot
- if the final submission must include the complete mobile application source code, the Flutter project should be placed under `src\` before final delivery

Suggested placement:

```text
src\WelloraFlutterApp
```

## Common Tools and Platforms for Web Application Deployment

The following tools and platforms are suitable for deployment and delivery of this project:

- Docker for containerized backend deployment
- GitHub Actions for CI/CD automation
- IIS or managed ASP.NET hosting for backend deployment
- Vercel or Netlify for a separate frontend client if the team later provides a web frontend
- Run-time hosting services such as MonsterASP.NET or similar ASP.NET hosting providers

## Recommended Submission Notes

To make the repository fully submission-ready:

1. Keep the complete source code inside `src/`
2. Keep the published backend output inside `exe/`
3. Add the Flutter source project if it is part of the required full-project submission
4. Remove real secrets from tracked configuration files before public sharing
5. Confirm database seeding or provide a small seed script for the three system roles

## Troubleshooting

### `dotnet` Command Not Found

Install the .NET 9 SDK, then restart PowerShell or your terminal.

### SQL Server Connection Error

Check:

- SQL Server is installed and running
- the connection string is correct
- the selected authentication mode matches the connection string

### Migration Failure

Make sure:

- SQL Server is reachable
- the connection string is valid
- you are using both `--project` and `--startup-project`

### Swagger Does Not Open

Check:

- the application started successfully
- the local port is `5291`
- the URL `/swagger` is correct

### CORS Errors

The current code explicitly allows specific frontend origins. If you run a local frontend client, the CORS policy in `Program.cs` may need adjustment.

## Conclusion

This repository provides a well-structured ASP.NET Core healthcare backend with clear setup, build, configuration, and execution instructions. It is suitable for academic submission as a clean source-code repository and is prepared for executable publishing through the `/exe` folder. For a fully complete end-to-end submission, the Flutter source application should be added if it is part of the required final deliverable.
