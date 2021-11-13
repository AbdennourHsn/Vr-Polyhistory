using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;

public class LightSittings : MonoBehaviour
{

    public GameObject[] disabdele;
    public GameObject lighting;
    bool Grabed;
    public HandAnimationControl hand;
    InputDevice RightDevice;
    InputDevice LeftDevice;
    public XRDirectInteractor lHand;
    public XRDirectInteractor rHand;

    // Start is called before the first frame update
    void Start()
    {

        List<InputDevice> DR = new List<InputDevice>();
        List<InputDevice> DL = new List<InputDevice>();

        InputDeviceCharacteristics RightCch = InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller;
        InputDeviceCharacteristics LeftCch = InputDeviceCharacteristics.Left | InputDeviceCharacteristics.Controller;

        InputDevices.GetDevicesWithCharacteristics(RightCch, DR);
        InputDevices.GetDevicesWithCharacteristics(LeftCch, DL);
        if (DR.Count > 0)
        {
            RightDevice = DR[0];
        }
        if (DL.Count > 0)
        {
            LeftDevice = DL[0];
        }

    }
    public void LightOn()
    {
        if(Grabed)
        lighting.SetActive(true);

    }
    public void LightOff()
    {
        if(Grabed)
        lighting.SetActive(false);

    }

    public void GrabedOn()
    {
        foreach (GameObject g in disabdele) g.SetActive(false);
        Grabed = true;
    }
    public void GrabedOff()
    {
        foreach (GameObject g in disabdele) g.SetActive(true);
        Grabed = false;
        hand.Reset();
    }

    private void Update()
    {

        if (Grabed)
        {
            RightDevice.TryGetFeatureValue(CommonUsages.trigger, out float TriggerValue);
            if (TriggerValue > 0.3f) { LightOn(); }
            else LightOff();
        }
    }
    public bool IsGrabed() { return Grabed; }
}
