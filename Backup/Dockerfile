#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Use the .NET 8 ASP.NET runtime as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

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

# Use Windows Server Core with IIS as the final image
FROM mcr.microsoft.com/windows/servercore/iis AS final

# Remove existing files from the IIS root
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

# Copy published application files to the IIS root
COPY --from=publish /app/publish/ C:/inetpub/wwwroot

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start the IIS process
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
