using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR;

public class InputsTest : MonoBehaviour
{
    
   public GameObject text;
    // Start is called before the first frame update
    void Start()
    {
         
        List<InputDevice> D = new List<InputDevice>();
        InputDevices.GetDevices(D);

        foreach(var item in D)
        {
            text.GetComponent<Text>().text = item.name;
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
