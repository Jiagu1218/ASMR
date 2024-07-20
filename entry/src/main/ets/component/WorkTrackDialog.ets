import { WorkTrack, WorkTracks } from '../net/WorkTrack'
import { Files } from './FilesNew'

@CustomDialog
export struct WorkTrackDialog {
  controllerTwo?: CustomDialogController
  showList?:WorkTracks
  @Link selectWorkTrack:WorkTrack|null
  build() {
    Column() {
      Files({stackList:[this.showList as WorkTracks],selectedWorkTrack:$selectWorkTrack})
    }
  }
}