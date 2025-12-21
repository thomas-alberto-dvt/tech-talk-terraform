plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "google" {
    enabled = true
    version = "0.37.1"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# ============================================
# REGLAS DE TERRAFORM (CORE)
# ============================================

# Detectar variables declaradas pero no utilizadas
rule "terraform_unused_declarations" {
  enabled = true
}

# Naming convention para recursos
rule "terraform_naming_convention" {
  enabled = true
  
  # Los nombres de recursos deben ser snake_case
  format = "snake_case"
}

