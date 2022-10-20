package usecase

type DatabasePlant interface {
	ListPlant() ([]Plant, error)
	SearchPlant([]int, []int) ([]Plant, error)
	InsertPlant(plant Plant) (bool, int, error)
	SetTagsToPlant(int, []string) error
}

type DatabaseTag interface {
	ListTag() ([]Tag, error)
}

type DatabaseNear interface {
	ListNear(float64, float64, float64) ([]Near, error)
}

type DatabasePlantTranslate interface {
	GetPlantIdentify(string) ([]string, error)
}

type DatabaseUploadPost interface {
	InsertUploadPost(UploadPostRequest, UploadPost) (UploadPostResponse, error)
}

var (
	DbPlant          DatabasePlant
	DbTag            DatabaseTag
	DbNear           DatabaseNear
	DbUploadPost     DatabaseUploadPost
	DbPlantTranslate DatabasePlantTranslate
)
