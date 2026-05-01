using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.API.Middleware
{
    public class LocalizedJsonResponseMiddleware
    {
        private readonly RequestDelegate _next;

        public LocalizedJsonResponseMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IAppLocalizationService localizationService)
        {
            var originalBody = context.Response.Body;
            await using var responseBody = new MemoryStream();
            context.Response.Body = responseBody;

            await _next(context);

            responseBody.Seek(0, SeekOrigin.Begin);

            if (!IsJsonResponse(context) && !IsPlainTextResponse(context))
            {
                await responseBody.CopyToAsync(originalBody);
                context.Response.Body = originalBody;
                return;
            }

            var body = await new StreamReader(responseBody, Encoding.UTF8).ReadToEndAsync();
            var localizedBody = IsJsonResponse(context)
                ? TryLocalizeJson(body, localizationService)
                : localizationService.TranslateText(body);

            context.Response.Body = originalBody;
            var bytes = Encoding.UTF8.GetBytes(localizedBody);
            context.Response.ContentLength = bytes.Length;
            await context.Response.Body.WriteAsync(bytes);
        }

        private static bool IsJsonResponse(HttpContext context) =>
            !string.IsNullOrWhiteSpace(context.Response.ContentType) &&
            context.Response.ContentType.Contains("application/json", StringComparison.OrdinalIgnoreCase);

        private static bool IsPlainTextResponse(HttpContext context) =>
            !string.IsNullOrWhiteSpace(context.Response.ContentType) &&
            context.Response.ContentType.Contains("text/plain", StringComparison.OrdinalIgnoreCase);

        private static string TryLocalizeJson(string json, IAppLocalizationService localizationService)
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return json;
            }

            JsonNode? rootNode;
            try
            {
                rootNode = JsonNode.Parse(json);
            }
            catch
            {
                return json;
            }

            if (rootNode is null)
            {
                return json;
            }

            LocalizeNode(rootNode, localizationService);
            return rootNode.ToJsonString(new JsonSerializerOptions(JsonSerializerDefaults.Web));
        }

        private static void LocalizeNode(JsonNode node, IAppLocalizationService localizationService, string? propertyName = null)
        {
            if (node is JsonObject jsonObject)
            {
                foreach (var property in jsonObject.ToList())
                {
                    if (property.Value is JsonValue value &&
                        value.TryGetValue<string>(out var stringValue) &&
                        ShouldTranslate(property.Key))
                    {
                        jsonObject[property.Key] = localizationService.TranslateText(stringValue);
                        continue;
                    }

                    if (property.Value is not null)
                    {
                        LocalizeNode(property.Value, localizationService, property.Key);
                    }
                }

                return;
            }

            if (node is JsonArray jsonArray)
            {
                for (var i = 0; i < jsonArray.Count; i++)
                {
                    var item = jsonArray[i];
                    if (item is JsonValue jsonValue &&
                        jsonValue.TryGetValue<string>(out var stringValue) &&
                        ShouldTranslate(propertyName))
                    {
                        jsonArray[i] = localizationService.TranslateText(stringValue);
                    }
                    else if (item is not null)
                    {
                        LocalizeNode(item, localizationService, propertyName);
                    }
                }
            }
        }

        private static bool ShouldTranslate(string? propertyName) =>
            propertyName is not null &&
            (propertyName.Equals("message", StringComparison.OrdinalIgnoreCase) ||
             propertyName.Equals("error", StringComparison.OrdinalIgnoreCase) ||
             propertyName.Equals("title", StringComparison.OrdinalIgnoreCase) ||
             propertyName.Equals("details", StringComparison.OrdinalIgnoreCase) ||
             propertyName.Equals("errors", StringComparison.OrdinalIgnoreCase));
    }
}
