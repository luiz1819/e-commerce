/*
  # Seed initial Nike product data

  1. Inserts filter data (genders, colors, sizes)
  2. Inserts brand (Nike)
  3. Inserts categories
  4. Inserts 15 Nike products with variants
  5. Inserts product images
*/

-- Insert genders
INSERT INTO genders (label, slug) VALUES 
('Men', 'men'),
('Women', 'women'),
('Kids', 'kids')
ON CONFLICT DO NOTHING;

-- Insert colors
INSERT INTO colors (name, slug, hex_code) VALUES 
('Black', 'black', '#000000'),
('White', 'white', '#FFFFFF'),
('Red', 'red', '#FF0000'),
('Blue', 'blue', '#0000FF'),
('Gray', 'gray', '#808080'),
('Green', 'green', '#008000'),
('Yellow', 'yellow', '#FFFF00'),
('Orange', 'orange', '#FFA500')
ON CONFLICT DO NOTHING;

-- Insert sizes
INSERT INTO sizes (name, slug, sort_order) VALUES 
('XS', 'xs', 1),
('S', 's', 2),
('M', 'm', 3),
('L', 'l', 4),
('XL', 'xl', 5),
('XXL', 'xxl', 6)
ON CONFLICT DO NOTHING;

-- Insert brand
INSERT INTO brands (name, slug, logo_url) VALUES 
('Nike', 'nike', 'https://www.nike.com/images/logo.png')
ON CONFLICT DO NOTHING;

-- Insert category
INSERT INTO categories (name, slug) VALUES 
('Running', 'running'),
('Basketball', 'basketball'),
('Casual', 'casual'),
('Training', 'training'),
('Football', 'football')
ON CONFLICT DO NOTHING;

-- Insert Nike products with variants and images
WITH inserted_products AS (
  INSERT INTO products (name, description, brand_id, category_id, gender_id, is_published) 
  SELECT 
    name, 
    description, 
    (SELECT id FROM brands WHERE slug = 'nike'),
    (SELECT id FROM categories WHERE slug = category_slug),
    (SELECT id FROM genders WHERE slug = gender_slug),
    true
  FROM (
    VALUES
    ('Nike Air Max 90', 'Classic comfortable Nike Air Max 90 sneaker with iconic design', 'casual', 'men'),
    ('Nike Air Force 1', 'Timeless Nike Air Force 1 basketball-inspired casual shoe', 'casual', 'men'),
    ('Nike Blazer Mid', 'Retro Nike Blazer with premium leather upper', 'casual', 'women'),
    ('Nike React Infinity Run', 'High-performance running shoe with React foam', 'running', 'men'),
    ('Nike Pegasus Turbo', 'Responsive running shoe for everyday runners', 'running', 'women'),
    ('Nike LeBron Witness VI', 'Professional basketball shoe with superior support', 'basketball', 'men'),
    ('Nike Kyrie 9', 'Elite basketball shoe designed for quick cuts and agility', 'basketball', 'men'),
    ('Nike Revolution 7', 'Lightweight running shoe perfect for beginners', 'running', 'kids'),
    ('Nike Court Borough Low', 'Versatile basketball-inspired casual sneaker', 'casual', 'women'),
    ('Nike Cortez', 'Heritage running shoe with classic silhouette', 'casual', 'women'),
    ('Nike Phantom GT', 'Professional soccer training shoe', 'football', 'men'),
    ('Nike Mercurial Vapor', 'Speed boot for competitive soccer players', 'football', 'men'),
    ('Nike ZoomX Streakfly', 'Lightweight distance running shoe', 'running', 'men'),
    ('Nike Metcon 8', 'Cross-training shoe for intense workouts', 'training', 'men'),
    ('Nike Free Metcon 4', 'Natural-feeling training shoe with barefoot sensation', 'training', 'women')
  ) AS p(name, description, category_slug, gender_slug)
  RETURNING id, name
),
colors_list AS (
  SELECT id, slug FROM colors WHERE slug IN ('black', 'white', 'red', 'blue', 'gray', 'green')
),
sizes_list AS (
  SELECT id, slug FROM sizes
),
variants_inserted AS (
  INSERT INTO product_variants (
    product_id, 
    sku, 
    price, 
    sale_price, 
    color_id, 
    size_id, 
    in_stock
  )
  SELECT
    p.id,
    'SKU-' || SUBSTRING(MD5(RANDOM()::TEXT), 1, 8),
    ROUND((90 + RANDOM() * 110)::NUMERIC, 2),
    CASE WHEN RANDOM() > 0.7 THEN ROUND((70 + RANDOM() * 80)::NUMERIC, 2) END,
    c.id,
    s.id,
    CAST(10 + RANDOM() * 50 AS INTEGER)
  FROM inserted_products p
  CROSS JOIN colors_list c
  CROSS JOIN sizes_list s
  WHERE RANDOM() > 0.5
  RETURNING id, product_id
)
INSERT INTO product_images (product_id, url, sort_order, is_primary)
SELECT
  v.product_id,
  'https://images.pexels.com/photos/shoe-' || CAST(RANDOM() * 15 + 1 AS INTEGER) || '.jpg',
  ROW_NUMBER() OVER (PARTITION BY v.product_id ORDER BY RANDOM()),
  TRUE
FROM variants_inserted v
WHERE RANDOM() > 0.3;
