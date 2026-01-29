import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI';
import {CurrentUser} from '../../../models/DTO/Auth'
import {
  UserElderRelationItem
} from '../../../models/DTO/intervention';
import { PlanFormRouteParams } from '../../common/InterventionPlanForm'
import { MedicalHealthDataParams } from '../data/MedicalHealthDataPage';
import { InterventionPlanListComp } from './InterventionPlanListComp';

@Builder
export function ElderInterventionPlanListBuilder (){
  ElderInterventionPlanList()
}

@Component
export struct ElderInterventionPlanList {
  @State private elderRelation: UserElderRelationItem | null = null
  @State private errorMsg: string = ''
  @State editable: boolean = false
  // Use a refresh counter to trigger list update on return
  @State private listRefreshId: number = 0
  @Consume('navPathStack') navPathStack: NavPathStack;

  private goToAddPlan() {
    if (!this.elderRelation) {
      return;
    }
    // FIX: Use elder_user_id (user account ID) instead of elder_id (elder_basic_info.id)
    const elderUserId = this.elderRelation.elder_user_id ?? this.elderRelation.elder_id
    const param: PlanFormRouteParams = { elderUserId: elderUserId };
    this.navPathStack.pushPathByName('Medical_Intervention_PlanForm', param);
  }

  private goToHealthData() {
    if (!this.elderRelation) {
      return;
    }
    const param: MedicalHealthDataParams = {
      elderId: this.elderRelation.elder_user_id ?? this.elderRelation.elder_id,
      elderName: this.elderRelation.elder.name
    };
    this.navPathStack.pushPathByName('Medical_HealthDataPage', param);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.elderRelation) {
            InterventionPlanListComp({
                elderUserId: this.elderRelation.elder_user_id ?? this.elderRelation.elder_id,
                showTabs: true,
                refreshId: this.listRefreshId
            })
        } else if (this.errorMsg) {
          Text(this.errorMsg).fontSize(14).fontColor('#dc2626').margin({ top: 50 })
        } else {
             LoadingProgress().width(40).height(40).margin({ top: 50 }).color('#2563eb')
        }
      }.width('100%').height('100%').backgroundColor('#f8fafc')
    }
    .title(this.elderRelation ? `${this.elderRelation.elder.name}的干预计划` : '干预计划')
    .menus([
      {
        value:"健康",
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.heart')), action: () => {
          this.goToHealthData()
        }
      },
      {
        value: $r('sys.symbol.plus'),
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
        action: () => {
          this.goToAddPlan()
        }
      }
    ])
    .hideToolBar(this.editable)
    .onReady((ctx: NavDestinationContext) => {
      console.info('[ElderInterventionPlanList] onReady called, param:', JSON.stringify(ctx.pathInfo.param))
      const param = ctx.pathInfo.param as UserElderRelationItem
      const user = AppStorage.get<CurrentUser>('currentUser');
      const roleCodes = user?.roles.map(role => role.role_code.toLowerCase())
      if(roleCodes && roleCodes.includes('medical_staff')){
        this.editable = true
      }else{
        this.editable = false
      }
      if (param && param.elder_id) {
        this.elderRelation = param
      } else {
        console.error('[ElderInterventionPlanList] Invalid param received')
        this.errorMsg = '参数错误，请返回重试'
      }
    })
    .onShown(() => {
      // Reload plans when returning to this page (e.g., after creating a plan item)
      if (this.elderRelation) {
         this.listRefreshId++;
      }
    })
  }
}
