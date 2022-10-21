package usecase

type DatabasePlant interface {
	ListPlant() ([]PlantHash, error)
	SearchPlant([]int, []int) ([]PlantHash, error)
	InsertPlant(string) (int, error)
	SetTagsToPlant(int, []string) error
	IsPlantExist(string) (bool, int, error)
}

type DatabaseTag interface {
	ListTag() ([]Tag, error)
}

type DatabaseNear interface {
	ListNear(float64, float64, float64) ([]Near, error)
}

type DatabasePlantTranslate interface {
	PlantTranslate([]string) ([]string, error)
	SearchPlantName([]string) ([]string, error)
}

type DatabaseUploadPost interface {
	InsertUploadPost(UploadPost) error
}

var (
	DbPlant          DatabasePlant
	DbTag            DatabaseTag
	DbNear           DatabaseNear
	DbUploadPost     DatabaseUploadPost
	DbPlantTranslate DatabasePlantTranslate
)
