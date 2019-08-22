

-----------------------------------------------------
module( "GTowerItems", package.seeall )

RegisterItem("ingredient_apple",{
	Name = "Apple",
	Description = "An ingredient to make smoothies with the blender.",
	Model = "models/sunabouzu/fruit/apple.mdl",
	DrawModel = true,
	StoreId = 25,
	StorePrice = 35,
	DrawName = true,
})

RegisterItem("ingredient_straw",{
	Base = "ingredient_apple",
	Name = "Strawberry",
	Model = "models/sunabouzu/fruit/strawberry.mdl",
})

RegisterItem("ingredient_watermel",{
	Base = "ingredient_apple",
	Name = "Watermelon",
	Model = "models/props_junk/watermelon01_chunk01b.mdl",
})

RegisterItem("ingredient_banana",{
	Base = "ingredient_apple",
	Name = "Banana",
	Model = "models/props/cs_italy/bananna.mdl",
})

RegisterItem("ingredient_orange",{
	Base = "ingredient_apple",
	Name = "Orange",
	Model = "models/props/cs_italy/orange.mdl",
})

RegisterItem("ingredient_glass",{
	Base = "ingredient_apple",
	Name = "Glass",
	Model = "models/props_junk/garbage_glassbottle001a.mdl",
})

RegisterItem("ingredient_plastic",{
	Base = "ingredient_apple",
	Name = "Plastic",
	Model = "models/props_junk/garbage_plasticbottle002a.mdl",
})

RegisterItem("ingredient_bone",{
	Base = "ingredient_apple",
	Name = "Bone",
	Model = "models/gibs/hgibs.mdl",
})
