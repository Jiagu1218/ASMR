import { WorkTrack, WorkTracks } from '../net/WorkTrack'
import { Files } from './FilesNew'

@CustomDialog
export struct WorkTrackDialog {
  controllerTwo?: CustomDialogController
  showList?:WorkTracks
  @Link selectWorkTrack:WorkTrack|null
  build() {
    Column() {
      Files({showList:this.showList,stackList:Array.of(this.showList as WorkTracks)})
    }
  }
}