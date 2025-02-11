-- Seed Data for Development and Testing

-- Insert fake users only if they don't exist
DO $$
DECLARE
    user1_id uuid;
    user2_id uuid;
BEGIN
    SELECT id INTO user1_id FROM auth.users WHERE email = 'testuser@keke.ceo';
    IF user1_id IS NULL THEN
        INSERT INTO auth.users (id, email, encrypted_password)
        VALUES (uuid_generate_v4(), 'testuser@keke.ceo', 'password1')
        RETURNING id INTO user1_id;
    END IF;

    SELECT id INTO user2_id FROM auth.users WHERE email = 'user2@example.com';
    IF user2_id IS NULL THEN
        INSERT INTO auth.users (id, email, encrypted_password)
        VALUES (uuid_generate_v4(), 'user2@example.com', 'password2')
        RETURNING id INTO user2_id;
    END IF;

    -- Insert brands
    IF NOT EXISTS (SELECT 1 FROM public.brand WHERE name = 'Brand A') THEN
        INSERT INTO public.brand (name, user_id)
        VALUES ('Brand A', user1_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.brand WHERE name = 'Brand B') THEN
        INSERT INTO public.brand (name, user_id)
        VALUES ('Brand B', user2_id);
    END IF;

    -- Insert item categories
    IF NOT EXISTS (SELECT 1 FROM public.item_category WHERE name = 'Shirts') THEN
        INSERT INTO public.item_category (name)
        VALUES ('Shirts');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.item_category WHERE name = 'Pants') THEN
        INSERT INTO public.item_category (name)
        VALUES ('Pants');
    END IF;

    -- Insert wardrobe items
    IF NOT EXISTS (SELECT 1 FROM public.wardrobe_item WHERE name = 'Casual Shirt') THEN
        INSERT INTO public.wardrobe_item (user_id, brand_id, category_id, name)
        VALUES (user1_id, (SELECT id FROM public.brand WHERE name = 'Brand A'), (SELECT id FROM public.item_category WHERE name = 'Shirts'), 'Casual Shirt');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.wardrobe_item WHERE name = 'Jeans') THEN
        INSERT INTO public.wardrobe_item (user_id, brand_id, category_id, name)
        VALUES (user2_id, (SELECT id FROM public.brand WHERE name = 'Brand B'), (SELECT id FROM public.item_category WHERE name = 'Pants'), 'Jeans');
    END IF;

    -- Insert outfits
    IF NOT EXISTS (SELECT 1 FROM public.outfit WHERE name = 'Summer Outfit') THEN
        INSERT INTO public.outfit (user_id, name)
        VALUES (user1_id, 'Summer Outfit');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.outfit WHERE name = 'Winter Outfit') THEN
        INSERT INTO public.outfit (user_id, name)
        VALUES (user2_id, 'Winter Outfit');
    END IF;

    -- Link wardrobe items to outfits
    IF NOT EXISTS (SELECT 1 FROM public.outfit_items WHERE outfit_id = (SELECT id FROM public.outfit WHERE name = 'Summer Outfit') AND wardrobe_item_id = (SELECT id FROM public.wardrobe_item WHERE name = 'Casual Shirt')) THEN
        INSERT INTO public.outfit_items (outfit_id, wardrobe_item_id)
        VALUES ((SELECT id FROM public.outfit WHERE name = 'Summer Outfit'), (SELECT id FROM public.wardrobe_item WHERE name = 'Casual Shirt'));
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.outfit_items WHERE outfit_id = (SELECT id FROM public.outfit WHERE name = 'Winter Outfit') AND wardrobe_item_id = (SELECT id FROM public.wardrobe_item WHERE name = 'Jeans')) THEN
        INSERT INTO public.outfit_items (outfit_id, wardrobe_item_id)
        VALUES ((SELECT id FROM public.outfit WHERE name = 'Winter Outfit'), (SELECT id FROM public.wardrobe_item WHERE name = 'Jeans'));
    END IF;

    -- Insert item usage
    IF NOT EXISTS (SELECT 1 FROM public.use_item WHERE wardrobe_item_id = (SELECT id FROM public.wardrobe_item WHERE name = 'Casual Shirt') AND user_id = user1_id) THEN
        INSERT INTO public.use_item (wardrobe_item_id, user_id)
        VALUES ((SELECT id FROM public.wardrobe_item WHERE name = 'Casual Shirt'), user1_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.use_item WHERE wardrobe_item_id = (SELECT id FROM public.wardrobe_item WHERE name = 'Jeans') AND user_id = user2_id) THEN
        INSERT INTO public.use_item (wardrobe_item_id, user_id)
        VALUES ((SELECT id FROM public.wardrobe_item WHERE name = 'Jeans'), user2_id);
    END IF;

    -- Insert outfit usage
    IF NOT EXISTS (SELECT 1 FROM public.use_outfit WHERE outfit_id = (SELECT id FROM public.outfit WHERE name = 'Summer Outfit') AND user_id = user1_id) THEN
        INSERT INTO public.use_outfit (outfit_id, user_id)
        VALUES ((SELECT id FROM public.outfit WHERE name = 'Summer Outfit'), user1_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.use_outfit WHERE outfit_id = (SELECT id FROM public.outfit WHERE name = 'Winter Outfit') AND user_id = user2_id) THEN
        INSERT INTO public.use_outfit (outfit_id, user_id)
        VALUES ((SELECT id FROM public.outfit WHERE name = 'Winter Outfit'), user2_id);
    END IF;

    -- Insert metadata
    IF NOT EXISTS (SELECT 1 FROM public.item_metadata WHERE wardrobe_item_id = (SELECT id FROM public.wardrobe_item WHERE name = 'Casual Shirt')) THEN
        INSERT INTO public.item_metadata (wardrobe_item_id, metadata)
        VALUES ((SELECT id FROM public.wardrobe_item WHERE name = 'Casual Shirt'), '{"color": "blue", "material": "cotton"}');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.item_metadata WHERE wardrobe_item_id = (SELECT id FROM public.wardrobe_item WHERE name = 'Jeans')) THEN
        INSERT INTO public.item_metadata (wardrobe_item_id, metadata)
        VALUES ((SELECT id FROM public.wardrobe_item WHERE name = 'Jeans'), '{"color": "black", "material": "denim"}');
    END IF;

END $$;
