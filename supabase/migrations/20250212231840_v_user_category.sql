CREATE OR REPLACE VIEW v_user_category_summary AS
SELECT 
    c.id AS category_id,
    c.name AS category_name,
    COUNT(w2.id) AS item_count,
    (
        SELECT w3.image_path 
        FROM wardrobe_item w3 
        WHERE w3.category_id = c.id 
        AND w3.user_id = w2.user_id
        ORDER BY random() -- Pick a random item image from the category
        LIMIT 1
    ) AS category_image,
    w2.user_id
FROM item_category c
LEFT JOIN wardrobe_item w2 ON w2.category_id = c.id
GROUP BY c.id, c.name, w2.user_id;
CREATE OR REPLACE FUNCTION get_user_category_summary()
RETURNS TABLE (
    category_id uuid,
    category_name text,
    user_id uuid,
    item_count bigint,
    category_image text
) 
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT 
        category_id,
        category_name,
        user_id,
        item_count,
        category_image
    FROM v_user_category_summary 
    WHERE user_id = auth.uid();
$$;

