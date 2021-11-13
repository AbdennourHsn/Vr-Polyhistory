using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR;

public class Inputs : MonoBehaviour
{
    public GameObject text;
    InputDevice RightDevice;
    // Start is called before the first frame update
    void Start()
    {

        List<InputDevice> D = new List<InputDevice>();

        InputDeviceCharacteristics RightCch = InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller;

        InputDevices.GetDevicesWithCharacteristics(RightCch, D);
        if(D.Count>0)
        {
            RightDevice = D[0];
        }

    }

    // Update is called once per frame
    void Update()
    {

        RightDevice.TryGetFeatureValue(CommonUsages.primaryButton, out bool primaryButton);
        if (primaryButton) text.GetComponent<Text>().text = "Clicked";
        RightDevice.TryGetFeatureValue(CommonUsages.trigger, out float TriggerValue);
        if (TriggerValue > 0.1f)
        {
            text.GetComponent<Text>().text = "Trigger " + TriggerValue;
        }

        RightDevice.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 axes);
        if (axes != Vector2.zero)
        {
            text.GetComponent<Text>().text = "Vector2 " + axes;
        }
    }


    
}
