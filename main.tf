resource "azurerm_resource_group" "rg_main" {
  name     = "RG_main_${var.location}_${var.environment}"
  location = var.location
}

module "vnet" {
    location = var.location
    rg_name = azurerm_resource_group.rg_main.name
    source = "./modules/vnet"
    depends_on = [ azurerm_resource_group.rg_main ]
}

module "cluster" {
    location = var.location
    rg_name = azurerm_resource_group.rg_main.name
    subnet_id = module.vnet.subnet_id
    source = "./modules/cluster"
    depends_on = [ module.vnet, module.NSG ]
}

module "NSG" {
    location = var.location
    rg_name = azurerm_resource_group.rg_main.name
    subnet_id = module.vnet.subnet_id
    source = "./modules/NSG"
    depends_on = [ module.vnet ]
}

provider "kubernetes" {
    host                   = module.cluster.kube_config.0.host
    client_certificate     = base64decode(module.cluster.kube_config.0.client_certificate)
    client_key             = base64decode(module.cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(module.cluster.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
      host                   = module.cluster.kube_config.0.host
      client_certificate     = base64decode(module.cluster.kube_config.0.client_certificate)
      client_key             = base64decode(module.cluster.kube_config.0.client_key)
      cluster_ca_certificate = base64decode(module.cluster.kube_config.0.cluster_ca_certificate)
  }
}