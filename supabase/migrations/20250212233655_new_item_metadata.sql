DROP TABLE IF EXISTS item_metadata;

CREATE TABLE item_metadata (
    id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
    wardrobe_item_id UUID REFERENCES wardrobe_item(id) ON DELETE CASCADE,
    bought_for NUMERIC(10,2),
    currency TEXT DEFAULT 'USD',
    purchase_date DATE,
    condition TEXT CHECK (condition IN ('New', 'Like New', 'Used', 'Vintage')),
    material TEXT,
    size TEXT,
    color TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


ALTER TABLE item_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own metadata"
ON item_metadata
FOR SELECT USING (
    EXISTS (SELECT 1 FROM wardrobe_item WHERE wardrobe_item.id = item_metadata.wardrobe_item_id AND wardrobe_item.user_id = auth.uid())
);
