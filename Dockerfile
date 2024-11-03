#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Use the .NET 8 ASP.NET runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-windowsservercore-ltsc2022 AS base
# Install IIS and configure
RUN dism /online /enable-feature /all /featurename:iis-webserver /NoRestart
# Enable ASP.NET Core in IIS
RUN powershell -NoProfile -Command \
    Add-WindowsFeature Web-Asp-Net-Core

# Set working directory in the container
WORKDIR /inetpub/wwwroot

# Expose default IIS HTTP port
EXPOSE 80

# Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["WebApplication1/WebApplication1.csproj", "WebApplication1/"]
RUN dotnet restore "./WebApplication1/WebApplication1.csproj"
COPY . .
WORKDIR "/src/WebApplication1"
RUN dotnet build "./WebApplication1.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./WebApplication1.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage with IIS
FROM base AS final
# Set the working directory in IIS
WORKDIR /inetpub/wwwroot
# Copy the application files to the IIS root
COPY --from=publish /app/publish .

# Start IIS Service Monitor
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]