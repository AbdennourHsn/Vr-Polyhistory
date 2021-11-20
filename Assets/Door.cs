using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : MonoBehaviour
{
    public float ZValue;
  public void OpenDood()
    {
        //LeanTween.rotateZ(gameObject, 40, 1);
        LeanTween.rotateAroundLocal(gameObject, new Vector3(0, 0 , 1), ZValue, 3) ;
    }

   
}
