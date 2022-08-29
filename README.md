
# Voice Recorder 
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-lightgrey) ![Xcode 13.3](https://img.shields.io/badge/Xcode-13.3-blue)
![Firebase](https://img.shields.io/badge/Firebase-9.3.0-orange)

- 사용자가 녹음하고 업로드, 삭제, 실행 할수 있는 앱 입니다.


## 팀원 소개 
| [@브랜뉴](https://github.com/Brandnew-one)                                                    | [@Kai](https://github.com/TaeKyeongKim)                                                    | [@Shin](https://github.com/dongeunshin)                                                       |
| ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| <img src="https://user-images.githubusercontent.com/36659877/178030910-4e17a9a6-2681-44ed-b5de-57444d42e31e.png" width="100" height="100"/> | <img src="https://avatars.githubusercontent.com/u/36659877?v=4" width="100" height="100"/> | <img src="https://user-images.githubusercontent.com/36659877/178031029-88b78f93-cda4-403d-ad09-5c7d71a0e9f9.png" width="100" height="100"/> |


### [팀 그라운드룰](https://github.com/TaeKyeongKim/VoiceRecorder-teamBSK/wiki/%08Home#%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C-%EB%A3%B0)
### 담당 화면 및 기술 
- `[PlayScene]` 브랜뉴: AVFoundation, UIGraphics 
- `[HomeScene]` Kai: Firebase Storage, CALayer 
- `[CreateAudioScene]` Shin: AVFoundation, CALayer

## 기능 구현 
### Home 화면
| **로드 완료 된 홈화면**|**Play 화면 전환**|
|---|---|
|<img src="https://user-images.githubusercontent.com/36659877/178033770-a0234859-1114-473b-8b1f-ba909157aa9e.png" width="200" height="400"/>|<img src="https://user-images.githubusercontent.com/36659877/178035769-052679e5-09a6-4edc-80cd-9446c5dc6632.gif" width="200" height="400"/>


|**Create Audio 화면 전환 및 파일 업로드**|**파일 삭제**|**서버 연결이 끊어질시 에러 핸들링**|
|---|---|---|
|<img src="https://user-images.githubusercontent.com/55118858/178104089-f5eb6fdb-8ba4-4a67-8296-20934c740295.gif" width="200" height="400"/>|<img src="https://user-images.githubusercontent.com/36659877/178037351-6eb6099b-ba96-447c-af96-0f6728fa3aca.gif" width="200" height="400"/>|<img src="https://user-images.githubusercontent.com/36659877/178036138-aa307f24-19bf-4f9d-a406-596631f6155f.gif" width="200" height="400"/>|




- [x] 파일명은 “현재 위치 _ 생성된 시간을 초 단위까지” 로 표시합니다.
- [x] 파일은 마지막으로 업로드된 파일부터 보여줍니다. 
- [x] 내비게이션 바 우상단에 + 버튼을 탭하면 녹음 화면(두 번째 화면)으로 이동합니다.
- [x] 파일을 탭하면 파일의 재생 화면(세 번째 화면)으로 이동합니다.
- [x] 새로운 녹음이 종료되면 녹음 리스트가 업데이트됩니다.
- [x] 리스트에서 스와이프 동작을 통해 파일을 삭제할 수 있습니다.
- [x] 서버 연결이 끊어질시 에러 핸들링

### Play 화면

| 음악 파형 및 세팅 | 오디오 플레이 화면 | Pitch 조절 |
|:---:|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/88618825/178092212-8ca8b829-c535-4703-9e88-653fca1776c6.gif" width="200" height="400"/>| <img src="https://user-images.githubusercontent.com/88618825/178092214-c441633b-db59-4cc8-9c19-e62a3f6a3a05.gif" width="200" height="400"/>| <img src="https://user-images.githubusercontent.com/88618825/178092216-adaa0097-22fd-4d12-b6c6-ebc73c8672c2.gif" width="200" height="400"/> |
 
- [x] 메인화면에서 선택된 녹음파일의 파형을 그려줍니다.
- [x] 버튼을 이용해 재생/정지, 5초 전,후를 조절할 수 있습니다.
- [x] 슬라이더를 통해 재생 위치를 변경할 수 있습니다.
- [x] 슬라이더를 통해 볼륨을 조절할 수 있습니다.
- [x] Segment Control를 통해 Pitch 값을 변경할 수 있습니다.

### CreateAudio 화면

| 녹음 시작 및 중지 | 버튼 비활성화 | 재녹음시 파일 대채 |
|:---:|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/55118858/178104570-2aa3045d-16cf-4848-b0db-d46856c7df6c.gif" width="200" height="400"/>| <img src="https://user-images.githubusercontent.com/55118858/178104762-e256cbfd-e551-4361-a22b-a2f31f2ddc67.gif" width="200" height="400"/>| <img src="https://user-images.githubusercontent.com/55118858/178104586-b6614c71-9ee6-480c-b701-0c33c367259b.gif" width="200" height="400"/> |

| 녹음 재생,일시정지,5초 전/후 이동 | 녹음 저장 |
|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/55118858/178104880-71236441-05fd-4d6a-8647-e9df473fa5ff.gif" width="200" height="400"/>| <img src="https://user-images.githubusercontent.com/55118858/178103713-3492e3bb-6821-4b48-8a88-d2ede6313005.gif" width="200" height="400"/>|
 
- [x] 녹음 버튼을 이용해 녹음 진행 및 정지를 할 수 있습니다.
- [x] 재생 버튼등을 이용해 녹음 완료된 파일을 재생/정지, 5초 전/후를 조절할 수 있습니다.
- [x] 녹음 중이거나 재생을 할때 파형을 그려줍니다. 
- [x] 녹음되고 있는 시간을 실시간으로 볼 수 있습니다.
- [x] 녹음 도중에는 녹음저장 및 재생을 할 수 없습니다.
- [x] 재 녹음시 새로운 녹음 파일로 대체됩니다.
- [x] Done 버튼을 이용해 녹음을 저장 할 수 있습니다.
- [x] Cancel 버튼을 이용해 녹음을 저장 하지 않고 되돌아 갈 수 있습니다.

### 그 외

| 녹음 권한 거절 | 녹음 권한 허용 |
|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/55118858/178107546-1976203d-f7b8-465e-b609-bb8321dc7d77.gif" width="200" height="400"/>| <img src="https://user-images.githubusercontent.com/55118858/178107540-cb0124af-c9df-4984-9fc0-8cbda658dff1.gif" width="200" height="400"/>|
- [x] 녹음 권한 요청 거절시 시스템 환경으로 이동합니다. 권한 허용없이는 녹음을 할 수 없습니다.
- [x] 녹음 권한 요청 허용시 녹음화면으로 갈 수 있습니다.

## 🤔 고민과 해결  
[Kai](https://github.com/TaeKyeongKim/VoiceRecorder-teamBSK/wiki/%EA%B3%A0%EB%AF%BC%EA%B3%BC-%ED%95%B4%EA%B2%B0) 




