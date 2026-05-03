# Executable Output Folder

Place published backend output in this directory.

Recommended command from the repository root:

```powershell
dotnet publish ".\src\WelloraHealthCareManagment\WelloraHealthCareManagment.API\WelloraHealthCareManagment.API.csproj" -c Release -o ".\exe\backend"
```

If publish succeeds, run the backend with:

```powershell
dotnet .\exe\backend\WelloraHealthCareManagment.API.dll
```
