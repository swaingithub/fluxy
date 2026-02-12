/// Simulated remote marketplace data.
/// In a real app, this would be fetched from an API endpoint.

class MarketplaceData {
  static const List<Map<String, dynamic>> templates = [
    {
      "id": "tpl_starter",
      "name": "Fluxy Starter",
      "description": "A minimal template with a counter and routing.",
      "author": "Fluxy Team",
      "version": "1.0.0",
      "preview": "https://raw.githubusercontent.com/fluxy/templates/main/starter/preview.png", // Hypothetical
      "manifestUrl": "https://raw.githubusercontent.com/fluxy/templates/main/starter/manifest.json" // Hypothetical
    },
    {
      "id": "tpl_commerce",
      "name": "E-Commerce Kit",
      "description": "Product listing, details, and cart flow using SDUI.",
      "author": "Community",
      "version": "0.5.0",
      "preview": "https://raw.githubusercontent.com/fluxy/templates/main/commerce/preview.png",
      "manifestUrl": "https://raw.githubusercontent.com/fluxy/templates/main/commerce/manifest.json"
    },
    {
      "id": "tpl_saas",
      "name": "SaaS Dashboard",
      "description": "Analytics dashboard with charts and data tables.",
      "author": "Pro Devs",
      "version": "2.1.0",
      "preview": "https://raw.githubusercontent.com/fluxy/templates/main/saas/preview.png",
      "manifestUrl": "https://raw.githubusercontent.com/fluxy/templates/main/saas/manifest.json"
    }
  ];

  static const List<Map<String, dynamic>> communityApps = [
    {
      "id": "app_todo",
      "name": "Super Todo",
      "author": "@dev_guru",
      "manifestUrl": "https://gist.githubusercontent.com/dev_guru/todo/raw/manifest.json"
    },
    {
      "id": "app_meditation",
      "name": "Zen Mind",
      "author": "@yoga_coder",
      "manifestUrl": "https://gist.githubusercontent.com/yoga_coder/zen/raw/manifest.json"
    }
  ];
}
