# Install once if needed:
# install.packages(c("tidyverse", "patchwork"))

library(tidyverse)
library(patchwork)

# 1) Load your dataset
pokemon <- read.csv("pokemon_pokedex_with_generation.csv")

# 2) Clean / prep
pokemon <- pokemon %>%
  mutate(
    Legendary = factor(Legendary, levels = c(0, 1), labels = c("Non-Legendary", "Legendary"))
  )

# -------------------------------
# PANEL A: Speed Distribution
# -------------------------------
p_speed <- ggplot(pokemon, aes(x = Speed)) +
  geom_histogram(binwidth = 10, fill = "#1f77b4", color = "white") +
  labs(
    title = "Speed Distribution",
    subtitle = "Wide range with a long right tail",
    x = "Speed",
    y = "Count"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# -------------------------------
# PANEL B: HP by Legendary
# -------------------------------
p_hp <- ggplot(pokemon, aes(x = Legendary, y = HP, fill = Legendary)) +
  geom_boxplot(width = 0.55, alpha = 0.85, outlier.alpha = 0.35) +
  scale_fill_manual(values = c("#9ecae1", "#ef3b2c")) +
  labs(
    title = "HP Spread by Class",
    subtitle = "HP shows large variability",
    x = NULL,
    y = "HP"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none",
    panel.grid.minor = element_blank()
  )

# -------------------------------
# PANEL C: Stats Comparison
# -------------------------------
stats_long <- pokemon %>%
  dplyr::select(Legendary, HP, Attack, Defense, Sp_Atk, Sp_Def, Speed) %>%
  pivot_longer(
    cols = c(HP, Attack, Defense, Sp_Atk, Sp_Def, Speed),
    names_to = "Stat",
    values_to = "Value"
  )

p_stats <- ggplot(stats_long, aes(x = Legendary, y = Value, fill = Legendary)) +
  geom_boxplot(width = 0.55, alpha = 0.85, outlier.alpha = 0.2) +
  scale_fill_manual(values = c("#9ecae1", "#ef3b2c")) +
  facet_wrap(~ Stat, nrow = 2) +
  labs(
    title = "Legendary Pokémon Rank Higher Across Stats",
    subtitle = "Median and upper quartiles are consistently higher",
    x = NULL,
    y = "Base Stat"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )

# -------------------------------
# PANEL D: Attack vs Sp_Atk
# -------------------------------
p_scatter <- ggplot(pokemon, aes(x = Attack, y = Sp_Atk, color = Legendary)) +
  geom_point(alpha = 0.55, size = 2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  scale_color_manual(values = c("#4c78a8", "#e15759")) +
  labs(
    title = "Attack vs Sp_Atk",
    subtitle = "Moderate relationship, distinct archetypes remain",
    x = "Attack",
    y = "Sp_Atk",
    color = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

# -------------------------------
# COMBINE ALL PANELS
# -------------------------------
final_plot <- (p_speed | p_hp) / (p_stats | p_scatter) +
  plot_annotation(
    title = "Exploratory Data Analysis in R Studio",
    subtitle = "Summary statistics reveal structural differences between Legendary and Non-Legendary Pokémon",
    theme = theme(
      plot.title = element_text(size = 18, face = "bold"),
      plot.subtitle = element_text(size = 12)
    )
  )

# Show plot
final_plot

# -------------------------------
# SAVE FOR GOOGLE SLIDES
# -------------------------------
ggsave(
  filename = "eda_summary_figure.png",
  plot = final_plot,
  width = 16,
  height = 9,
  dpi = 300,
  bg = "white"
)



# Create clean Legendary variable
pokemon <- pokemon %>%
  mutate(
    Legendary = trimws(as.character(Legendary)),
    Legendary = case_when(
      Legendary %in% c("0") ~ "Non-Legendary",
      Legendary %in% c("1") ~ "Legendary",
      TRUE ~ NA_character_
    )
  )

# Create class counts
class_counts <- pokemon %>%
  filter(!is.na(Legendary)) %>%
  count(Legendary)

# Check it worked
print(class_counts)

# Extract values
non_legendary_n <- class_counts %>%
  filter(Legendary == "Non-Legendary") %>%
  pull(n)

legendary_n <- class_counts %>%
  filter(Legendary == "Legendary") %>%
  pull(n)

pct_non_legendary <- round(non_legendary_n / sum(class_counts$n) * 100)

# Plot
p_class <- ggplot(class_counts, aes(x = Legendary, y = n, fill = Legendary)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = n), vjust = -0.3, size = 6) +
  scale_fill_manual(values = c("Non-Legendary" = "#1b224f", "Legendary" = "#d90000")) +
  scale_y_continuous(limits = c(0, max(class_counts$n) * 1.15)) +
  labs(
    title = "Class Imbalance: Legendary vs Non-Legendary",
    subtitle = paste0(
      non_legendary_n, " Non-Legendary | ",
      legendary_n, " Legendary | ",
      pct_non_legendary, "% Non-Legendary"
    ),
    x = NULL,
    y = "Count"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )

print(p_class)
