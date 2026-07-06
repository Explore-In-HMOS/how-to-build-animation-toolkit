import { common } from '@kit.AbilityKit';
import image from '@ohos.multimedia.image';
import {
  AnimatedDrawableDescriptor,
  AnimationController,
  AnimationOptions,
  DrawableDescriptor
} from '@ohos.arkui.drawableDescriptor';

export type AnimationControllerModule = AnimationController;

export class AnimationDescriptorFactory {
  static createClockFrames(context: common.UIAbilityContext): AnimatedDrawableDescriptor {
    const resourceNames: Array<string> = [
      'icon_foreground_orbit',
      'icon_foreground_bolt',
      'icon_badge_star',
      'icon_foreground_route'
    ];
    const frames: Array<image.PixelMap> = [];

    try {
      for (let index = 0; index < resourceNames.length; index++) {
        const descriptor:DrawableDescriptor=context.resourceManager.getDrawableDescriptorByName(resourceNames[index]);
        frames.push(descriptor.getPixelMap());
      }
    } catch (error) {
      throw new Error('Unable to create animation frames from app media resources.');
    }

    const options: AnimationOptions = {
      duration: 1120,
      iterations: -1,
      frameDurations: [240, 320, 180, 380],
      autoPlay: false
    };
    return new AnimatedDrawableDescriptor(frames, options);
  }
}
