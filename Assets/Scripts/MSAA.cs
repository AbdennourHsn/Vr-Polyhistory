using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MSAA : MonoBehaviour
{

        public int antiAliasing = 4;
        // Use this for initialization
        void Start()
        {
            QualitySettings.antiAliasing = antiAliasing;
        }
    
}
  