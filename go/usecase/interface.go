package usecase

import "context"

type DatabasePlant interface {
	ListPlant(context.Context) ([]PlantHash, error)
	SearchPlant(context.Context, []int, []int) ([]PlantHash, error)
	InsertPlant(context.Context, string) (int, error)
	SetTagsToPlant(context.Context, int, []string) error
	IsPlantExist(context.Context, string) (bool, int, error)
}

type DatabaseTag interface {
	ListTag(context.Context) ([]Tag, error)
}

type DatabaseNear interface {
	ListNear(context.Context, float64, float64, float64) ([]Near, error)
}

type DatabasePlantTranslate interface {
	SearchPlantName(context.Context, []string) ([]string, error)
}

type DatabaseUploadPost interface {
	InsertUploadPost(context.Context, UploadPost) error
}

var (
	DbPlant          DatabasePlant
	DbTag            DatabaseTag
	DbNear           DatabaseNear
	DbUploadPost     DatabaseUploadPost
	DbPlantTranslate DatabasePlantTranslate
)
