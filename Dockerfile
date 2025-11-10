# === 1. Base Image (تشغيل التطبيق) ===
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7092

# إعدادات مهمة لـ ngrok و Google Login
ENV ASPNETCORE_URLS=http://+:7092
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_FORWARDEDLIMIT=1

# === 2. Build Stage (ترجمة الكود) ===
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# نسخ ملف المشروع
COPY ["HealthCare_.csproj", "."]
RUN dotnet restore "HealthCare_.csproj"

# نسخ باقي الكود
COPY . .
WORKDIR "/src"
RUN dotnet build "HealthCare_.csproj" -c Release --no-restore

# === 3. Publish Stage (إنشاء الملفات الجاهزة) ===
FROM build AS publish
RUN dotnet publish "HealthCare_.csproj" -c Release --no-build -o /app/publish

# === 4. Final Image (النسخة النهائية) ===
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# تشغيل التطبيق
ENTRYPOINT ["dotnet", "HealthCare_.dll"]