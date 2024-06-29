import { Article } from '../entity/Article'
import { Queue } from '@kit.ArkTS';
import { ArkTSUtils } from '@kit.ArkTS'
import { WebResource } from '../util/WebResoucre';
import emitter from '@ohos.events.emitter';
import { LogUtil } from '../util/LogUtil';

class DataSourcePool {
  private pageNum: number = 1;
  private pageSize: number = 10;
  private webDataSources: Queue<Article> = new Queue();
  private lock: ArkTSUtils.locks.AsyncLock = ArkTSUtils.locks.AsyncLock.request('webDataSources_lock');

  async getData(size: number = 5): Promise<Article[]> {
    const result: Article[] = [];
    LogUtil.info('DataSourcePool getData length length ' + this.webDataSources.length);
    for (let i = 0; i < size; i++) {
      if (this.webDataSources.length <= 0) {
        break;
      }
      if (this.webDataSources.length < (size * 2)) {
        await this.getFromWeb(); // 等待获取数据
      }
      result.push(this.webDataSources.pop());
    }
    return result;
  }

  private async addData(...articles: Article[]): Promise<void> {
    LogUtil.info('DataSourcePool addData length ' + articles.length);
    await this.lock.lockAsync(async () => {
      articles.forEach(item => this.webDataSources.add(item));
    });
  }

  resetPool(): void {
    this.pageNum = 1;
    this.webDataSources = new Queue();
  }

  private async getFromWeb(): Promise<void> {
    const result = await WebResource.getListHtmlResource(this.pageNum);
    await this.addData(...result);
    this.pageNum++;
  }

  async init(): Promise<void> {
    const result = await WebResource.getListHtmlResource(this.pageNum);
    await this.addData(...result);
    emitter.emit("dataSourcePool_init");
    this.pageNum++;
  }
}

let dataSourcePool = new DataSourcePool();
export default dataSourcePool;
