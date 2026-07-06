import { common } from '@kit.AbilityKit';
import { AnimatedDrawableDescriptor, Animator, AnimatorResult, SimpleAnimatorOptions } from '@kit.ArkUI';
import { AnimationControllerModule, AnimationDescriptorFactory } from './AnimationDescriptorFactory';

const HERO_DESTINATION: string = 'workoutHero';

class HeroNavParam {
  source: string = 'motionAtlas';
}

@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack();
  @State keyframeScale: number = 1;
  @State keyframeColor: string = '#7FE7FF';
  @State orbitX: number = 0;
  @State orbitY: number = -34;
  @State expanded: boolean = false;
  @State simpleValue: number = 0;
  @State controllerState: string = 'Ready';
  @State selectedPattern: number = 0;

  private drawableAnimation?: AnimatedDrawableDescriptor;
  private drawableController?: AnimationControllerModule;
  private valueAnimator?: AnimatorResult;
  private orbitReturnsToStart: boolean = false;
  private readonly patternNames: Array<string> = [
    'Keyframes', 'Orbit', 'Geometry', 'Hero', 'Control', 'Options', 'Value'
  ];

  aboutToAppear(): void {
    this.prepareDrawableAnimation();
    this.prepareValueAnimator();
  }

  aboutToDisappear(): void {
    if (this.valueAnimator) {
      this.valueAnimator.cancel();
    }
    if (this.drawableController) {
      this.drawableController.stop();
    }
  }

  prepareDrawableAnimation(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      this.drawableAnimation = AnimationDescriptorFactory.createClockFrames(context);
      this.controllerState = 'Drawable frames ready';
    } catch (error) {
      this.controllerState = 'Drawable resource unavailable';
    }
  }

  prepareValueAnimator(): void {
    const options = new SimpleAnimatorOptions(0, 1)
      .duration(900)
      .delay(120)
      .easing('ease-in-out')
      .iterations(-1);
    this.valueAnimator = this.getUIContext().createAnimator(options);
    this.valueAnimator.onFrame = (value: number): void => {
      this.simpleValue = value;
    };
    this.valueAnimator.play();
  }

  playKeyframes(): void {
    this.getUIContext().keyframeAnimateTo({ iterations: 1 }, [
      {
        duration: 150,
        curve: Curve.EaseOut,
        event: (): void => {
          this.keyframeScale = 1.24;
          this.keyframeColor = '#FFE66D';
        }
      },
      {
        duration: 210,
        curve: Curve.Sharp,
        event: (): void => {
          this.keyframeScale = 0.86;
          this.keyframeColor = '#FF78A8';
        }
      },
      {
        duration: 260,
        curve: Curve.EaseInOut,
        event: (): void => {
          this.keyframeScale = 1;
          this.keyframeColor = '#7FE7FF';
        }
      }
    ]);
  }

  toggleOrbit(): void {
    const targetX = this.orbitReturnsToStart ? 0 : 0.1;
    this.getUIContext().animateTo({ duration: 1300, curve: Curve.Linear }, (): void => {
      this.orbitX = targetX;
      this.orbitY = -34;
    });
    this.orbitReturnsToStart = !this.orbitReturnsToStart;
  }

  toggleGeometry(): void {
    this.expanded = !this.expanded;
  }

  openHeroDetail(): void {
    this.pathStack.pushPathByName(HERO_DESTINATION, new HeroNavParam(), true);
  }

  closeHeroDetail(): void {
    this.pathStack.pop(true);
  }

  captureController(): void {
    if (!this.drawableAnimation) {
      this.controllerState = 'Frames are not ready';
      return;
    }
    this.drawableController = this.drawableAnimation.getAnimationController('clock-frame-preview');
  }

  startDrawable(): void {
    this.captureController();
    if (this.drawableController) {
      this.drawableController.start();
      this.controllerState = `Playing: ${this.drawableController.getStatus()}`;
    }
  }

  pauseDrawable(): void {
    this.captureController();
    if (this.drawableController) {
      this.drawableController.pause();
      this.controllerState = `Paused: ${this.drawableController.getStatus()}`;
    }
  }

  resetDrawable(): void {
    this.captureController();
    if (this.drawableController) {
      this.drawableController.stop();
      this.controllerState = `Stopped: ${this.drawableController.getStatus()}`;
    }
  }

  selectPattern(index: number): void {
    // A chip can be pressed again while its card is already being rebuilt.
    // Avoid replacing the same card, and stop a drawable controller before
    // its Image leaves the component tree.
    if (this.selectedPattern === index) {
      return;
    }
    if (this.selectedPattern === 4 && this.drawableController) {
      this.drawableController.stop();
    }
    this.selectedPattern = index;
  }

  @Builder
  PatternChip(label: string, index: number): void {
    Text(label)
      .fontSize(7)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedPattern === index ? '#10141A' : '#C7D0DB')
      .padding({ left: 7, right: 7, top: 5, bottom: 5 })
      .backgroundColor(this.selectedPattern === index ? '#7FE7FF' : '#252D38')
      .borderRadius(11)
      .onClick(() => this.selectPattern(index))
  }

  @Builder
  SectionTitle(index: number, title: string, subtitle: string): void {
    Row({ space: 7 }) {
      Text(`${index + 1}`)
        .width(18)
        .height(18)
        .fontSize(8)
        .fontWeight(FontWeight.Bold)
        .fontColor('#10141A')
        .backgroundColor('#7FE7FF')
        .borderRadius(9)
        .textAlign(TextAlign.Center)
      Column({ space: 1 }) {
        Text(title).fontSize(10).fontWeight(FontWeight.Bold).fontColor('#F7FAFC')
        Text(subtitle).fontSize(7).fontColor('#93A2B5').maxLines(1)
      }
    }
    .width('100%')
  }

  @Builder
  SmallButton(label: string, action: () => void): void {
    Text(label)
      .height(24)
      .layoutWeight(1)
      .fontSize(8)
      .fontWeight(FontWeight.Medium)
      .fontColor('#10141A')
      .backgroundColor('#B9F5CC')
      .borderRadius(12)
      .textAlign(TextAlign.Center)
      .onClick(action)
  }

  @Builder
  KeyframeDemo(): void {
    Column({ space: 6 }) {
      this.SectionTitle(0, 'Keyframe pulse', 'Per-keyframe duration and curves')
      Row({ space: 9 }) {
        Circle()
          .width(25)
          .height(25)
          .fill(this.keyframeColor)
          .scale({ x: this.keyframeScale, y: this.keyframeScale })
        Text('150 · EaseOut  →  210 · Sharp  →  260 · EaseInOut')
          .fontSize(7)
          .fontColor('#C7D0DB')
          .layoutWeight(1)
          .maxLines(2)
        Text('Run')
          .fontSize(8)
          .fontColor('#10141A')
          .padding({ left: 9, right: 9, top: 6, bottom: 6 })
          .backgroundColor('#FFE66D')
          .borderRadius(12)
          .onClick(() => this.playKeyframes())
      }
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 0 ? 1 : 0, color: '#7FE7FF' })
  }

  @Builder
  MotionPathDemo(): void {
    Column({ space: 5 }) {
      this.SectionTitle(1, 'Circular motion path', 'SVG arc trajectory for a clock marker')
      Stack({ alignContent: Alignment.Center }) {
        Circle().width(76).height(76).fill('#111820').stroke('#3E4B5C').strokeWidth(1)
        Circle().width(6).height(6).fill('#7FE7FF')
          .translate({ x: this.orbitX, y: this.orbitY })
          .motionPath({
            path: 'M start.x start.y A 34 34 0 1 1 0 34 A 34 34 0 1 1 end.x end.y',
            from: 0,
            to: 1,
            rotatable: false
          })
        Text('orbit').fontSize(7).fontColor('#93A2B5')
      }
      .width(82)
      .height(82)
      Text('Trace orbit').fontSize(8).fontColor('#10141A').padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#B9F5CC').borderRadius(12).onClick(() => this.toggleOrbit())
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 1 ? 1 : 0, color: '#7FE7FF' })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  GeometryDemo(): void {
    Column({ space: 6 }) {
      this.SectionTitle(2, 'Geometry transition', 'One identifier, two wearable layouts')
      Row({ space: 8 }) {
        Row({ space: 6 }) {
          Circle().width(this.expanded ? 34 : 20).height(this.expanded ? 34 : 20).fill('#FF78A8')
          Column({ space: 1 }) {
            Text(this.expanded ? 'Recovery details' : 'Recovery').fontSize(9).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
            Text(this.expanded ? 'Slow down for 90 sec' : 'Tap to expand').fontSize(7).fontColor('#93A2B5')
          }.alignItems(HorizontalAlign.Start)
        }
        .geometryTransition('recovery-card', { follow: true })
        .padding(this.expanded ? 10 : 6)
        .backgroundColor(this.expanded ? '#303C4B' : '#252D38')
        .borderRadius(this.expanded ? 14 : 9)
        .layoutWeight(1)
        Text(this.expanded ? 'Close' : 'Open').fontSize(8).fontColor('#7FE7FF').onClick(() => this.toggleGeometry())
      }
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 2 ? 1 : 0, color: '#7FE7FF' })
  }

  @Builder
  HeroDemo(): void {
    Column({ space: 6 }) {
      this.SectionTitle(3, 'Shared hero transition', 'Shared Transition across detail navigation')
      Row({ space: 9 }) {
        Stack({ alignContent: Alignment.Center }) {
          Circle().width(35).height(35).fill('#624CBB')
          Text('12').fontSize(10).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        }
        .sharedTransition('workout-hero', { duration: 420, curve: Curve.EaseInOut, type: SharedTransitionEffectType.Exchange })
        Column({ space: 2 }) {
          Text('Recovery ring').fontSize(9).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
          Text('Navigate to hero detail').fontSize(7).fontColor('#93A2B5')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('View').fontSize(8).fontColor('#10141A').padding({ left: 9, right: 9, top: 6, bottom: 6 })
          .backgroundColor('#7FE7FF').borderRadius(12).onClick(() => this.openHeroDetail())
      }
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 3 ? 1 : 0, color: '#7FE7FF' })
  }

  @Builder
  ControllerDemo(): void {
    Column({ space: 6 }) {
      this.SectionTitle(4, 'AnimationController', 'Programmatic frame playback control')
      Row({ space: 9 }) {
        if (this.drawableAnimation) {
          Image(this.drawableAnimation).id('clock-frame-preview').width(36).height(36).objectFit(ImageFit.Contain)
        } else {
          Circle().width(36).height(36).fill('#3E4B5C')
        }
        Text(this.controllerState).fontSize(7).fontColor('#C7D0DB').layoutWeight(1).maxLines(2)
        Row({ space: 4 }) {
          Text('▶').fontSize(9).fontColor('#10141A').padding(6).backgroundColor('#B9F5CC').borderRadius(12).onClick(() => this.startDrawable())
          Text('Ⅱ').fontSize(8).fontColor('#10141A').padding(6).backgroundColor('#FFE66D').borderRadius(12).onClick(() => this.pauseDrawable())
          Text('↺').fontSize(9).fontColor('#10141A').padding(6).backgroundColor('#FFB9CC').borderRadius(12).onClick(() => this.resetDrawable())
        }
      }
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 4 ? 1 : 0, color: '#7FE7FF' })
  }

  @Builder
  OptionsDemo(): void {
    Column({ space: 5 }) {
      this.SectionTitle(5, 'AnimationOptions', 'Drawable frame duration and playback policy')
      Text('duration 1120 ms  ·  iterations -1  ·  [240, 320, 180, 380] ms  ·  autoPlay false')
        .fontSize(7).fontColor('#C7D0DB').maxLines(2)
      Text('Delay and curve belong to the ArkUI animation modifier, not AnimationOptions.')
        .fontSize(7).fontColor('#FFE66D').maxLines(2)
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 5 ? 1 : 0, color: '#7FE7FF' })
  }

  @Builder
  SimpleAnimatorDemo(): void {
    Column({ space: 6 }) {
      this.SectionTitle(6, 'SimpleAnimatorOptions', 'Lightweight 0→1 breathing value')
      Row({ space: 8 }) {
        Circle().width(20 + this.simpleValue * 16).height(20 + this.simpleValue * 16).fill('#7FE7FF').opacity(0.45 + this.simpleValue * 0.55)
        Text(`value ${this.simpleValue.toFixed(2)}  ·  900 ms  ·  delay 120  ·  ease-in-out`)
          .fontSize(7).fontColor('#C7D0DB').layoutWeight(1).maxLines(2)
      }
    }
    .width('100%')
    .padding(9)
    .backgroundColor('#1A222D')
    .borderRadius(12)
    .border({ width: this.selectedPattern === 6 ? 1 : 0, color: '#7FE7FF' })
  }

  @Builder
  HeroDetailPage(): void {
    Column({ space: 14 }) {
      Text('Back')
        .fontSize(10)
        .fontColor('#7FE7FF')
        .width('78%')
        .onClick(() => this.closeHeroDetail())

      Stack({ alignContent: Alignment.Center }) {
        Circle().width(150).height(150).fill('#1A222D').stroke('#624CBB').strokeWidth(3)
        Circle().width(104).height(104).fill('#624CBB').opacity(0.35)
        Text('12').fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      }
      .sharedTransition('workout-hero', { duration: 420, curve: Curve.EaseInOut, type: SharedTransitionEffectType.Exchange })

      Column({ space: 4 }) {
        Text('Recovery ring').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text('A shared hero grows from the compact watch card into the destination view.')
          .fontSize(8).fontColor('#AAB8C8').textAlign(TextAlign.Center).maxLines(3)
      }
      .width('72%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 30, bottom: 20 })
    .backgroundColor('#10141A')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DestinationMap(name: string, param: Object): void {
    if (name === HERO_DESTINATION) {
      NavDestination() {
        this.HeroDetailPage()
      }
      .hideTitleBar(true)
      .backgroundColor('#10141A')
    }
  }

  @Builder
  AtlasPage(): void {
    Column({ space: 8 }) {
      Column({ space: 2 }) {
        Text('Motion Atlas').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text('Seven wearable animation patterns').fontSize(7).fontColor('#93A2B5')
      }
      .width('78%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Row({ space: 4 }) {
          this.PatternChip(this.patternNames[0], 0)
          this.PatternChip(this.patternNames[1], 1)
          this.PatternChip(this.patternNames[2], 2)
          this.PatternChip(this.patternNames[3], 3)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        Row({ space: 4 }) {
          this.PatternChip(this.patternNames[4], 4)
          this.PatternChip(this.patternNames[5], 5)
          this.PatternChip(this.patternNames[6], 6)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('78%')

      Scroll() {
        Column({ space: 7 }) {
          if (this.selectedPattern === 0) {
            this.KeyframeDemo()
          } else if (this.selectedPattern === 1) {
            this.MotionPathDemo()
          } else if (this.selectedPattern === 2) {
            this.GeometryDemo()
          } else if (this.selectedPattern === 3) {
            this.HeroDemo()
          } else if (this.selectedPattern === 4) {
            this.ControllerDemo()
          } else if (this.selectedPattern === 5) {
            this.OptionsDemo()
          } else {
            this.SimpleAnimatorDemo()
          }
        }
        .width('100%')
        .padding({ bottom: 8 })
      }
      .layoutWeight(1)
      .width('78%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 30, bottom: 18 })
    .backgroundColor('#10141A')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Navigation(this.pathStack) {
      this.AtlasPage()
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.DestinationMap)
    .width('100%')
    .height('100%')
    .backgroundColor('#10141A')
  }
}