import { WorkTrack, WorkTracks } from '../net/WorkTrack'
import { Files } from './Files'

@CustomDialog
export struct WorkTrackDialog {
  controllerTwo?: CustomDialogController
  showList?:WorkTracks
  @Link selectWorkTrack:WorkTrack|null
  build() {
    Column() {
      Files({showList:this.showList,selectWorkTrack:$selectWorkTrack})
    }
  }
}